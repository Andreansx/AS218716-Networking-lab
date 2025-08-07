# Lab for learning

This repository serves as a documentation of infrastructure, configurations, projects etc. that take place in my lab as a way of developing skills that are neccesary in my dream field of work. I would love to work in a datacenter environment, especially in things like backbone engineering and server administration.  


<div align=“center”>

![MikroTik](https://img.shields.io/badge/mikrotik-2B0948?style=for-the-badge&logo=mikrotik&logoColor=white)
![Proxmox](https://img.shields.io/badge/proxmox-542045?style=for-the-badge&logo=proxmox&logoColor=white)
![Debian](https://img.shields.io/badge/debian-7D3742?style=for-the-badge&logo=debian&logoColor=white)
![FreeBSD](https://img.shields.io/badge/freebsd-A54E3E?style=for-the-badge&logo=freebsd&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-CE653B?style=for-the-badge&logo=terraform&logoColor=white)

</div>


## Table of Contents
1.  [Featured Projects](#featured-projects)
2.  [How This Repository Is Organized](#how-this-repository-is-organized)
3.  [Lab Architecture](#lab-architecture)
    *   [Network Diagram](#network-diagram)
    *   [VLAN & IP Schema](#vlan—ip-schema)
4.  [Hardware](#hardware)
5.  [Projects](#projects)
6.  [Physical Build Log](#physical-build-log)
7.  [Contact](#contact)

# Featured projects

Here are the things that I think are the most worth checking out.  

*   **[Addressation modernization, better management](./projects/04-management-network-split)**

*   **[L3 hardware offload instead of router-on-a-stick](./projects/03-l3-hw-offload-on-core-switch)** - Super fast port-speed connection for wide bandwith between Virtual Machines !

* **[IPv6](./IPv6/)** - This is what I am most focused on. You can check out this directory to see what I'm doing on my way to get a IPv6 routed /64 block (or maybe even /48 )  

* [Enabling VLAN30 access with a Dual-Port 10GbE NIC](./projects/02-vlan30-access-without-sfp-transreceivers)  

<!-- [LXC with RouterOS Wiki Local mirror](./IaC/terraform_routeros_wiki_lxc/)
-->

## How This Repository Is Organized

This repository is structured to be a clear and useful reference. Here’s a map of the key directories:

*   **/[device-name]/** (e.g., [`./ccr2004/`](./ccr2004/), [`./r710/`](./r710/)): Contains the latest configuration files and documentation for each piece of hardware. This is the source of truth for device settings.
*   **`/IaC/`**: Holds all Infrastructure as Code projects, primarily using Terraform to automate deployments on Proxmox.
*   **`/docs/`**: Contains details about plans for improving the lab. For example a better addressation plan


## Lab Architecture

### Network Diagram

This diagram shows the physical and logical topology of the lab.

![topology](./media/topology.png)

## VLAN & IP Schema

The network is segmented using VLANs. For now there are three main VLANs.

| ID  & Name    | Network | Where | Description                                   |
|:---|:---|:---|:---|
| 20 - Bare Metal | 10.1.2.0/27         | Routed on Core-CRS326 | Here are bare-metal devices. For example, the PVE Host is here on 10.1.2.30/27.        |
| 30 - Users | 10.1.3.0/24         | Routed on Core-CCR2004 | This is the VLAN for users.     |
| 40 - VMs/LXCs | 10.1.4.0/24       | Routed on Core-CRS326  | Here are placed Virtual Machines accessible through `vmbr0` |

There are also dedicated VLANs for management and traffic tranzit.

*   **VLAN 100** - This is the VLAN used for the `inter-router-link0` interface. Both the CCR2004 and CRS326 have interfaces in this VLAN. 
    CCR2004 - `10.2.1.1/30`
    CRS326  - `10.2.1.2/30`
*   **VLAN 111** - This is where the management SVI for the CCR2004 is. The CCR2004 has a `10.1.1.1/30` IP here.
*   **VLAN 115** - Here is the management SVI for the CRS326 on the `10.1.1.5/30` IP Address.

## Hardware

A list of the key components in my lab. Click a device name to see its configuration files.

| Device Type      | Model                                   | Role in the Lab                                   |
|:---|:---|:---|
| **Server Rack**  | [HPE 10636 G2](./hpe-10636-g2/)         | Central mounting point for all equipment.         |
| **Server**       | [Dell PowerEdge R710](./r710/)          | Main virtualization host, running Proxmox VE.     |
| **Server**       | [Dell PowerEdge R610](./r610/)          | Currently unused, planned for a giveaway.         |
| **Core Router**  | [MikroTik CCR2004](./ccr2004/)           | Core router. Handles routing, firewall and NAT.       |
| **Core Switch**  | [MikroTik CRS326](./crs326/)           | Main switch, inter-VLAN routing handling, L2/L3 switching. |
| **Switch**| [Brocade FastIron LS648](./ls648/)      | A device for testing and L3 firmware experimentation.      |
| **PDU**          | [HP S1132](./hpe-s1132/)                | Enterprise-grade Power Distribution Unit.                  |

## Projects

This is where the real learning happens. Here are some of the things I’ve built or am currently working on.

### Active Directory

*   **[First Active Directory scenario](./projects/01-ActiveDirectory-first-scenario)**

### Networking
*   **[l3 hardware offload instead of router-on-a-stick](./projects/03-l3-hw-offload-on-core-switch)**  
*   **[Repurposing a spare NIC for creating 10GbE VLAN access ports without SFP+ transreceivers](./projects/02-vlan30-access-without-sfp-transreceivers)**

### Infrastructure as Code (IaC)

*   **[Terraform RouterOS Wiki LXC](./IaC/terraform_routeros_wiki_lxc/)**: Deploys a local copy of the MikroTik Wiki in an LXC using Terraform.
*   **[Terraform First Deployment](./IaC/terraform_first_deployment/)**: My initial project for deploying a simple CentOS LXC on Proxmox.

### Guides & External Repositories

*   **[Unbound DNS Resolver (repo)](https://github.com/andreansx/unbound-homelab)**: WIP - Deployment of a recursive DNS server for the lab.
*   **[Simple VLANs on RouterOS (repo)](https://github.com/andreansx/routeros-simple-vlans)**: A guide to basic VLAN configuration on MikroTik devices.


## Physical Build Log

See how the lab was physically assembled and cabled.

*   **[Server Rack Installation](./installs/installation-rack/)**
*   **[Cabling and Keystone Jack Installation](./installs/installation-keystones/)**

—

## Contact

[![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/Andrtexh)
