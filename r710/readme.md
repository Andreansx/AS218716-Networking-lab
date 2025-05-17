# Overview of my Dell R710 server

## Specs
*   **CPU:** 2x Intel Xeon X5670 
*   **C/T:** 12C/24T
*   **Memory:** 128 GB DDR3 ECC Skhynix & Samsung
*   **Disk space:** Combined 1.6 TB of HDD SAS disk space

## System
**This server is running Proxmox version 7.8 ( gonna reinstall with latest ISO )**

## Related files
* **[BIOS 6.6.0](./BIOS_0F4YY_LN_6.6.0.BIN) - BIOS image to flash using iDRAC**
* **[BIOS 6.6.0](./BIOS_0YV9D_LN_6.6.0.BIN) - BIOS image to flash using iDRAC**
* **[All in one](./r-710-bootable_archive.torrent) - .exe file to update every firmware on the R710. Including Lifecycle controller, BIOS, RAID controller. Needs to be executed with for example a FreeDOS shell from a USB Drive.**
<div align="center">
<h2>Configuration files</h2>
</div>

**[/etc/network/interfaces](./etc/network/interfaces)**
```bash
auto lo
iface lo inet loopback

auto eno4
iface eno4 inet manual

iface eno1 inet manual

auto eno2
iface eno2 inet manual

auto eno3
iface eno3 inet manual

iface enp6s0f0 inet manual

iface enp6s0f1 inet manual

auto vmbr0
iface vmbr0 inet static
        address 10.0.0.130/24
        gateway 10.0.0.1
        bridge-ports eno1 eno2
        bridge-stp off
        bridge-fd 0
        default-gateway 10.0.0.1

source /etc/network/interfaces.d/*
```

**[/etc/hosts](./etc/hosts)**
```bash
127.0.0.1 localhost.localdomain localhost
10.0.0.120 idrac
10.0.0.130 r710homelab.pve r710homelab
```
