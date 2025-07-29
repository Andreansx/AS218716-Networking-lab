# Project: Repurposing a NIC for Cost-Effective VLAN Access Ports on Proxmox VE

## 1. Objective

The primary objective was to establish 10GbE network connectivity in an adjacent room by utilizing two pre-installed Cat6A ethernet runs. My first consideration was to use SFP+ 10G-RJ45 transceivers in the core Mikrotik CRS326, but this was economically impractical for just my environment.

The alternative I thought about was to repurpose a spare dual-port 10GbE RJ45 NIC and install it in the main Proxmox VE host. The technical goal was to configure these physical ports (`enp7s0f0`, `enp7s0f1`) to function as L2 access ports, automatically tagging all untagged ingress traffic into **VLAN 30**. This project demonstrates the use of the hosts underlying Linux networking stack to perform advanced layer 2 functions without depending on Proxmox-specific features.

## 2. System Environment

-   **Hypervisor Host:** Dell PowerEdge R710 running Proxmox VE
-   **Uplink NIC:** `enp6s0` (10GbE SFP+)
-   **Access NIC:** `enp7s0f0`, `enp7s0f1` (Dual-port 10GbE RJ45)
-   **Core L2/L3 Switch:** Mikrotik CRS326-24S+2Q+ (RouterOS v7.19.3)
-   **Core L3 Router/DHCP Server:** Mikrotik CCR2004-1G-12S+2XS

## 3. Configuration & Troubleshooting Iterations

I achieved the final solution through a very long process of implementation and debugging, since I wasn't really that familiar with the Linux networking functions neccessary for this.

### 3.1. Dual-Bridge Architecture

-   **Concept:** Create two separate Linux bridges. `vmbr1` for the access ports and a virtual `vlan30` interface to tag traffic, with `vmbr0` for the uplink.
-   **Result:** Failure.
-   **Technical Analysis:** `tcpdump` analysis showed DHCP requests arriving on the ingress port but never appearing on the egress port. This configuration created two isolated L2 domains. The attempt to link them by adding the `vlan30` virtual interface as a port to `vmbr0` is not a valid method for forwarding traffic between bridges in the Linux networking stack.

### 3.2. Single-Bridge with High-Level Directives

-   **Concept:** Consolidate all physical ports into a single, VLAN-aware bridge (`vmbr0`) and attempt to use high-level directives like `bridge-pvid` directly in `/etc/network/interfaces`.
-   **Result:** Failure.
-   **Technical Analysis:** This approach failed because the version of `ifupdown2` used by Debian/Proxmox did not support the necessary advanced syntax for defining per-port PVIDs and tagged memberships directly as high-level directives. That configuration was either ignored or incorrectly applied



