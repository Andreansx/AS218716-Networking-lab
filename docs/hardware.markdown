##  Detailed Hardware Overview

My networking lab consists of servers, routers, switches, and other devices.  
Here’s a brief overview:


###  Servers

#### [Dell PowerEdge R710](../dell-poweredge-r710/)

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

#### [MikroTik CCR2004-1G-12S+2XS](../ccr2004-1g-12s+2xs/)

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