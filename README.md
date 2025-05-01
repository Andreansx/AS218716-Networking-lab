# Welcome 👋
## Happy to see you visiting this repository dedicated to general documentation of my networking lab.

![Dell](https://img.shields.io/badge/dell-%230012b3?style=for-the-badge&logo=dell)
![Proxmox](https://img.shields.io/badge/proxmox-proxmox?style=for-the-badge&logo=proxmox&logoColor=%23E57000&labelColor=%232b2a33&color=%232b2a33)
![Cloudflare](https://img.shields.io/badge/Cloudflare-F38020?style=for-the-badge&logo=Cloudflare&logoColor=white)
![MikroTik](https://img.shields.io/badge/MikroTik-%23363636?style=for-the-badge&logo=Mikrotik)

---

## 🧠 About This Repository

This repository serves as an overview of my physical networking lab.  
It documents my current devices, setup, goals, and the methodology behind my learning journey.

My lab is designed for **serious, hands-on learning**. It's where I test realistic scenarios, experiment with routing and switching protocols, and simulate environments similar to those found in ISPs and data centers.

Each specific lab scenario (e.g., BGP testing, VLAN setups) will be developed separately in **dedicated repositories** for easier modularity.

---

##  Hardware Overview

My networking lab consists of servers, routers, switches, and other devices.  
Here’s a brief overview:

---

###  Servers

#### [Dell PowerEdge R710](./dell-poweredge-r710/)

A much older but still functional server—loud, power-hungry, but enough for lab purposes.

- Dual Intel Xeon X5670 (12 cores / 24 threads, 2.9 GHz)
- 128 GB DDR3 ECC RDIMM (Samsung + SK Hynix)
- Dual 870W PSUs
- 2x 10GbE RJ45 NIC (currently unused)
- 4x 1GbE RJ45 NIC
- iDRAC 6 Enterprise Remote access 
- Drives:
  - 146 GB Dell-certified SAS 15K HDD (Proxmox)
  - 600 GB Dell-certified SAS 10K HDD
  - 900 GB HGST SAS 10K HDD

 _Although it's not a cutting-edge configuration, it allows me to experiment and run basic services. I plan to upgrade to a used Dell PowerEdge R740 in the future to significantly expand my lab capabilities._

#### Dell PowerEdge R610

Honestly, this server is mostly e-waste at this point.  
However, it’s still takes some space in my room.

- Dual Xeon E5520
- 36 GB DDR3 ECC RDIMM
- Dual 717W PSUs

 _It will most likely scrapped for parts soon._

---

###  Routers

#### ISP Router (Provided by VICTOR)

- GPON ONT + Router
- 4x 1GbE RJ45 ports
- 1x SC/APC fiber connector

 _The internet service is generally good (low latency ~6-7ms), but lack of admin access to the router is a security limitation._

---

#### [MikroTik CCR2004-1G-12S+2XS](./ccr2004-1g-12s+2xs/)

An absolute beast for labbing advanced routing protocols.

- 1x 1GbE RJ45 (Management)
- 12x SFP+ ports (10GbE)
- 2x SFP28 ports (25GbE)
- 4 GB RAM (RouterOS 7) / 1700 MB (RouterOS 6)
- 256 KB flash memory
- 4 ARM cores at 1.7 GHz

Supports BGP, OSPF, VPN tunneling, MPLS, and other data-center level features.

---

#### MikroTik CRS326-24S+2Q+RM

Another powerful device. It has L3 features and it is an important part of the lab.

- 1x 1GbE RJ45 Management port
- 24x SFP+ ports ( 10GbE )
- 2x QSFP+ ( 40GbE )

---

## 🛠️ Current Focus Areas of this repository

- Documentiation of latest configuration of the devices
- Providing links to standalone repositories dedicated to specific scenarios
- Storing backups of the configurations in case of a failure
- Potentially storing notes I take
- Storing details about physical wiring in the lab