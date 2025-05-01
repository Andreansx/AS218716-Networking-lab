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

My lab is designed for **serious, hands-on learning**. It's where I test realistic scenarios, experiment with routing and switching protocols, and try to simulate environments similar to those found in ISPs and data centers.

Each specific lab scenario (e.g., BGP testing, VLAN setups) will be documented separately in **dedicated repositories** for easier modularity.  
However, **manual installations** of copper cables, fiber patchcords etc. will be documented in the **[/docs](./docs/)** folder in this repository, as it wouldn't make sense to create new repositories just for the sake of those short tasks.

## Manual installations

*   **[Keystones and copper cable through wall installation](./docs/keystones-installation.md)**

## Standalone scenarios / services repositories

All different scenarios, setups, services and projects are placed in their own, **standalone repositories**.  
Below you can find links to all of them: 

  _Here will be the list_

## Hardware Overview

Below you can find a short list of devices that my current lab consists of.  
The details you can find **[here](./docs/hardware.md)**

  The lab consist of servers such as **Dell PowerEdge R710**, used as a Proxmox host, and a R610 which does not have any current use.
  There also are networking devices such as **CCR2004** and a **CRS326** from **MikroTik**.
  I even have a very old **Brocade FastIron LS648-STK** switch that required some tinkering to enable L3 functionality.


## 🛠️ Current Focus Areas of this repository

- Documentiation of latest configuration of the devices
- Providing links to standalone repositories dedicated to specific scenarios
- Storing backups of the configurations in case of a failure
- Potentially storing notes I take
- Storing details about physical wiring in the lab