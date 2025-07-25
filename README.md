
# Networking Homelab - Documentation Hub

Welcome to the documentation hub for my home lab. This repository serves as the main overview of the infrastructure, configurations, and projects I'm working on as I develop my skills towards a career in network engineering, server administration, and cloud solutions.

### Tools and Technologies

![MikroTik](https://img.shields.io/badge/mikrotik-3D2817?style=for-the-badge&logo=mikrotik&logoColor=white)
![Proxmox](https://img.shields.io/badge/proxmox-6A2322?style=for-the-badge&logo=proxmox&logoColor=white)
![Debian](https://img.shields.io/badge/debian-971E2E?style=for-the-badge&logo=debian&logoColor=white)
![FreeBSD](https://img.shields.io/badge/freebsd-C41939?style=for-the-badge&logo=freebsd&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-F11444?style=for-the-badge&logo=terraform&logoColor=white)
---

## Table of Contents

1.  **[Repository Guide](#repository-guide)**
2.  [Hardware](#hardware)
3.  [Lab Architecture](#lab-architecture)
    *   [Network Diagram](#network-diagram)
    *   [Logical Topology (VLAN & IP)](#logical-topology-vlan--ip)
4. [Projects](#projects)
5. [Physical Installation Documentation](#physical-installation-documentation)
6. [Contact](#contact)
---

## Repository Guide

This repository contains configuration files, notes, firmware, and photo documentation. Without any idea on how to look through it, things can get messy. I put a nice way of exploring this repository:

**1. First, it may be the best idea to look at the diagram showing the topology of the network. Look at [Network Diagram](#network-diagram)**

**2. Then, the most interesting thing is to look into specific projects and deployments that take place in the lab. They are listed below in the [Projects](#projects) section, and are split into regular and IaC directories. You can also see [`./docs/`](./docs/). For example there is a new IPv4 addressation plan.**

**3. You can afterwards browse through individual configuration files. The most important ones are listed here:**

-   [`./ccr2004/`](./ccr2004/) & [`./crs326/`](./crs326/) - **Core Router and Switch**
    -   Contain **latest** `config.rsc` files, which are configuration exports from the MikroTik devices. They can be used to restore settings.
    -   General description and overview in `readme.md` files

-   [`./r710/`](./r710/) - **Virtualization**
    -   Proxmox Virtual Environment configuration files.
    -   `./r710/etc/network/interfaces` - The network configuration for the Proxmox VE host, defining the `vmbr0` bridge and VLAN handling.
    -   Informations about VMs and CTs.
    -   This directory also contain BIOS files and other notes.

-   [`./IaC/`](./IaC/) - As said above, **Infrastructure as Code** projects
    -   Directories for individual deployments. Each contain its own neccessary HCL code and a readme file.

**4. If you want, you can take a peek at the physical part of homelabbing. Look at [Physical installation documentation](#physical-installation-documentation)**

## Lab Architecture

### Network Diagram

The diagram below illustrates the overall physical and logical topology of the lab.

![topology](./media/topology.png)

### Logical Topology (VLAN & IP)

The network is segmented using VLANs to isolate traffic and enhance security. The core of the network is built around a **MikroTik CCR2004** router and a **MikroTik CRS326** switch.

| VLAN ID | Name         | Subnet / IP Scheme | Description                                                                                                                              |
| :------ | :----------- | :----------------- | :--------------------------------------------------------------------------------------------------------------------------------------- |
| 10      | Management   | `10.10.10.0/24`    | Network for managing network devices such as the router and switch.                                              |
| 20      | Bare-metal   | `10.10.20.0/24`    | Network for physical servers and devices. The R710 server's management interface lives here at `10.10.20.201` (untagged on a hybrid port). |
| 30      | Users        | `10.10.30.0/24`    | Main network for end-user devices like laptops and phones.                                                                               |
| 40      | VMs-CTs      | `10.10.40.0/24`    | Dedicated network for VMs and Containers on the Proxmox host. Traffic is tagged and carried over the hybrid SFP+ port.                 |

---

## Hardware

Below is a list of the key components in the lab. Click the name to navigate to its specific documentation and configuration files.

| Device Type      | Model                                   | Role in the Lab                                   |
| :--------------- | :-------------------------------------- | :------------------------------------------------ |
| **Server Rack**  | [HPE 10636 G2](./hpe-10636-g2/)         | Central mounting point for all equipment.         |
| **Server**       | [Dell PowerEdge R710](./r710/)          | Main virtualization host, running Proxmox VE.     |
| **Server**       | [Dell PowerEdge R610](./r610/)          | Currently unused, planned for a giveaway.         |
| **Core Router**  | [MikroTik CCR2004](./ccr2004/)           | Core router. Handles inter-VLAN routing and NAT.       |
| **Core Switch**  | [MikroTik CRS326](./crs326/)           | Main switch, VLAN handling, L2/L3 switching. |
| **Switch**| [Brocade FastIron LS648](./ls648/)      | A device for testing and L3 firmware experimentation.      |
| **PDU**          | [HP S1132](./hpe-s1132/)                | Enterprise-grade Power Distribution Unit.                  |

## Projects

Here are listed projects that occur in this lab environment.

### Projects in different repositories

-   **[Unbound DNS Resolver](https://github.com/andreansx/unbound-homelab)** - Deployment of a recursive DNS server. WIP.
-   **[Simple VLANs on RouterOS](https://github.com/andreansx/routeros-simple-vlans)** - A guide to configuring simple VLANs on MikroTik.

### IaC Deployments

-   [`IaC/terraform_first_deployment`](./IaC/terraform_first_deployment/)
    -   First simple Terraform code for deploying a CentOS LXC on my Proxmox VE server

### Networking Projects


## Physical Installation Documentation

Find photo galleries of the installation process in the links below.

-   **[Server Rack Installation](./installs/installation-rack/)**
-   **[Cabling and Keystone Jack Installation](./installs/installation-keystones/)**

## Contact

[![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/Andrtexh)
