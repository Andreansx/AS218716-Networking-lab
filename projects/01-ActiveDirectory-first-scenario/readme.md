# First scenario with Windows Server Active Directory technology

The objective of this project actually was to just get more familiar with Windows Server Active Directory, since I never really used it.  

Some of the key technologies used here are:
*   **Proxmox Virtual Environment 8.4.5**
*   **Windows Server** (Active Directory, DC, GPO)
*   **Debian 12**
*   **Samba**

In order to complete the objective I created a fictional company named **testcorp.local**.  

# Topology diagram

![diagram](./diagram.png)

# Configuration

Below is just a write-down of the steps taken in order to complete this project.

## Core - Domain Controller

### Configuration

-   Installed Windows Server 2022 Datacenter evaluation on a VM in Proxmox VE  
-   Installed role **Active Directory Domain Services**.  
-   Created new forest and new domain "testcorp.local".  
-   Installed role DNS for the Domain Controller  

### Management

-   Created new OU (Organizational Unit) structure:  
```
testcorp.local
    _Users
        Sales
        Designers
        IT
    _PCs
        Laptops
        Workstations
```
-   Added some example users in the appropriate OU.  

### Joining the domain

-   Created another VM in Proxmox VE but this time with regular Windows 10.  
-   Added the IP of the Domain Controller (10.100.40.10) as the DNS.  
-   Joined the machine to the domain.  
-   Logged in as one of the example users I created.  

## Central Management


To automate client configuration and enforce company policies, a Group Policy Object (GPO) was created and linked to the "Designers" OU.

The GPO implements the following settings for users in the "Designers" group:
-   **Desktop Wallpaper:** Enforces a standardized desktop background across all workstations. The wallpaper file is stored centrally on the `\netlogon` share of the domain controller.
-   **Security Restrictions:** Disables access to the Control Panel and modern Settings app to prevent unauthorized changes.
-   **Drive Mapping:** Automatically maps a network drive `Z:` to the central file share `\\FS01\Designers`, providing easy access to project files.

## Linux Integration - File Server (Samba)

A lightweight Debian 12 LXC container (FS01) was deployed to serve as a cost-effective and high-performance file server.

### Configuration Steps:
-   Installed Samba and necessary Kerberos/Winbind packages (`samba`, `krb5-user`, `winbind`, etc.).
-   **Joined the Linux server to the `testcorp.local` domain.** This allows for seamless authentication using Active Directory accounts.
-   Created a network share named `[Designers]` pointing to the `/srv/samba/Designers` directory.
-   Assigned file system permissions using AD groups (`chown Administrator:"Domain Users" ...`), allowing domain users to read/write to the share.

# Project Troubleshooting Log: Integrating Samba with Active Directory

The section below covers my troubleshooting process undertaken to resolve a persistent issue with joining a Debian 12 (Samba) server to a Windows Server Active Directory domain. The initial `net ads join` command repeatedly failed with Kerberos-related errors, despite a seemingly correct setup.

## Initial Problem

The `net ads join -U Administrator` command consistently failed with the following errors:

```
gse_get_client_auth_token: gss_init_sec_context failed with [ Miscellaneous failure (see text): FAST fast response is missing FX-FAST (...)]
ads_sasl_spnego_bind: kinit succeeded but SPNEGO bind with Kerberos failed for ldap/dc01.testcorp.local: The attempted logon is invalid.
```

This indicated a deep-seated problem with Kerberos authentication between the Linux client (`FS01`) and the Domain Controller (`DC01`).

## Investigation & Resolution Steps

### DNS Resolution (External)

-   The `FS01` container was unable to install packages using `apt`, failing with `Temporary failure resolving 'deb.debian.org'`.
-   **Diagnosis:** The container's DNS was correctly pointed at the Domain Controller (`10.100.40.10`). However, the DC's DNS server role only knew how to resolve internal `*.testcorp.local` names and had no mechanism to resolve external internet addresses.
-   **Resolution:** Configured **DNS Forwarders** on the `DC01`'s DNS server role. All queries for non-authoritative zones are now forwarded to an upstream DNS resolver ( Pi-Hole, 1.1.1.1). This immediately solved the package installation issue.

### Kerberos "FAST" Mechanism

-   Even with DNS working, the `join` command still produced the `FAST fast response is missing` error.
-   **Diagnosis:** FAST (Flexible Authentication Secure Tunneling) is a modern Kerberos extension that "armors" the initial authentication exchange. Newer Samba versions try to use it by default, but it can be incompatible with some Windows Server configurations.
-   **Resolution:** Disabled FAST on the Linux client by adding `disable_fast = true` to the `[libdefaults]` section of `/etc/krb5.conf`.

### Kerberos Configuration (`krb5.conf`)

-   The problem persisted. A review of `/etc/krb5.conf` revealed it was the default Debian file, filled with example realms (MIT.EDU, etc.) but lacking an explicit definition for my own realm.
-   **Diagnosis:** The Kerberos client was likely confused, unable to reliably locate the Key Distribution Center (KDC) for `TESTCORP.LOCAL`.
-   **Resolution:** Replaced the entire `/etc/krb5.conf` with a clean, minimal configuration explicitly defining the `TESTCORP.LOCAL` realm and pointing the `kdc` and `admin_server` to `dc01.testcorp.local`.

### Firewall on Domain Controller

-   A `tcpdump` analysis of the network traffic showed the `DC01` server was actively terminating connections from `FS01` with TCP Reset packets (`[R.]`). This pointed to a network-level block.
-   **Diagnosis:** I suspected the Windows Defender Firewall on `DC01` of blocking the incoming Kerberos, LDAP, and RPC traffic from an "untrusted" Linux client.
-   **Resolution (Diagnostic Step):** The firewall on `DC01` was temporarily disabled for all profiles to test this theory. **The issue, however, persisted**, ruling out the firewall as the primary cause.

### Time Synchronization (The actual cause)

-   All previous steps failed. This suggested a fundamental issue. Kerberos is extremely sensitive to time skew between clients and servers, typically failing if the skew exceeds 5 minutes.
-   **Diagnosis:**
    1.  An attempt to run `chrony` (NTP client) inside the `FS01` LXC container failed with an `Operation not permitted` error. This revealed that LXC containers, by default, cannot change the system clock, as they share the kernel with the Proxmox host. Time must be synchronized on the host.
    2.  `chronyc sources` on the Proxmox host, after configuring it to sync with `DC01`, showed a time offset of **-32397 seconds (approximately 9 hours)**.
    3.  The final breakthrough came from inspecting the `DC01` server's settings directly in the Server Manager GUI. Its timezone was incorrectly set to **UTC-8 (Pacific Time)**, while the Proxmox host and container were operating in a European timezone.
-   **Resolution:**
    1.  The timezone on the `DC01` Windows Server was corrected to **UTC+1 (Central European Time)**.
    2.  `chrony` was installed on the Proxmox host to ensure it was perfectly synchronized with the now-correct time on `DC01`.
    3.  The `FS01` container's timezone was explicitly set to `Europe/Warsaw` to match the rest of the infrastructure.

**With the time and timezone issues resolved across all three systems (DC01, Proxmox Host, FS01 Container), the `net ads join` command succeeded instantly and without errors.**

### Final thoughts

This long troubleshooting process reminded me of a critical principle of Active Directory environments: **proper time synchronization is not optional, it is a fundamental requirement for Kerberos authentication to function.** The misleading `FAST` and `SPNEGO` errors were masking the true, underlying problem of a massive time skew between the server and the client.
