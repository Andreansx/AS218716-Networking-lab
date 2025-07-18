
# Networking Homelab - Documentation Hub

Welcome to the documentation hub for my home lab. This repository serves as the main overview of the infrastructure, configurations, and projects I'm working on as I develop my skills towards a career in network engineering, server administration, and cloud solutions.

### Tools and Technologies

![MikroTik](https://img.shields.io/badge/mikrotik-3D2817?style=for-the-badge&logo=mikrotik&logoColor=white)
![Proxmox](https://img.shields.io/badge/proxmox-762126?style=for-the-badge&logo=proxmox&logoColor=white)
![Debian](https://img.shields.io/badge/debian-B51B35?style=for-the-badge&logo=debian&logoColor=white)
![FreeBSD](https://img.shields.io/badge/freebsd-F11444?style=for-the-badge&logo=freebsd&logoColor=white)

---

## Table of Contents

1.  [Lab Architecture](#lab-architecture)
    *   [Network Diagram](#network-diagram)
    *   [Logical Topology (VLAN & IP)](#logical-topology-vlan--ip)
2.  [Hardware](#hardware)

---

## Lab Architecture

### Network Diagram

The diagram below illustrates the overall physical and logical topology of the lab.


![topology](./media/topology.png)

### Logical Topology (VLAN & IP)

The network is segmented using VLANs to isolate traffic and enhance security. The core of the network is built around a **MikroTik CCR2004** router and a **MikroTik CRS326** switch. The `ip-list.md` file contains a detailed list of all assigned IP addresses.

| VLAN ID | Name         | Subnet / IP Scheme | Description                                                                                                                              |
| :------ | :----------- | :----------------- | :--------------------------------------------------------------------------------------------------------------------------------------- |
| 10      | Management   | `10.10.10.0/24`    | Network for managing network devices (router, switches, PDU) and the Proxmox web interface.                                              |
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



## Contact

[![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/Andrtexh)
