# Lab for learning

This repository serves as a documentation of infrastructure, configurations, projects etc. that take place in my lab as a way of developing skills that are neccesary in my dream field of work. I would love to work in a datacenter environment, especially in things like backbone engineering and server administration.  


<div align=“center”>

![MikroTik](https://img.shields.io/badge/mikrotik-2B0948?style=for-the-badge&logo=mikrotik&logoColor=white)
![Proxmox](https://img.shields.io/badge/proxmox-542045?style=for-the-badge&logo=proxmox&logoColor=white)
![kubernetes](https://img.shields.io/badge/kubernetes-7D3742?style=for-the-badge&logo=kubernetes&logoColor=white)
![FreeBSD](https://img.shields.io/badge/freebsd-A54E3E?style=for-the-badge&logo=freebsd&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-CE653B?style=for-the-badge&logo=terraform&logoColor=white)

</div>

> [!CAUTION]
> There has been a big issue with the last network configuration especially on PVE. Contact with web GUI was completly cut off and even OSPF backbone went down. 
> All because of a massive broadcast storm and loops that occured between the CRS326 and the Proxmox VE. 
Please read [OSPF and L2 Loop troubleshooting](./projects/11-ospf-and-l2-loop) as it may be really relevant in case some other things might have stopped working. 
> I now used the correct approach to do what I intended but without the risk of a gigantic broadcast storm.  
> (It turned out that everything was caused by a L1 Loop)

## Table of Contents
1.  [Docs to read](#docs-to-read)
2.  [How This Repository Is Organized](#how-this-repository-is-organized)
3.  [Lab Architecture](#lab-architecture)
    *   [Network Diagram](#network-diagram)
    *   [VLAN & IP Schema](#vlan—ip-schema)
4.  [Hardware](#hardware)
5.  [Projects](#projects)
6.  [Physical Build Log](#physical-build-log)
7.  [Contact](#contact)

# Docs to read

Here I put things that I think are the most interesting and worth reading.   

These are projects, case studies and troubleshooting logs.    

*   **[eBGP Implementation between two AS'es](./projects/12-eBGP-implementation/readme.md)** - Plus DHCP Nightmare


*   **[Super Important OSPF and L2 Loop troubleshooting](./projects/11-ospf-and-l2-loop/readme.md)** - This is important as it makes some changes to the entire lab archtecture. 

*   **[Finally OSPF Implementation !](./projects/06-ospf-backbone)** - Area 0 between CCR2004 and CRS326   

*   **[Addressation modernization, better management](./projects/04-management-network-split)**

*   **[L3 hardware offload instead of router-on-a-stick](./projects/03-l3-hw-offload-on-core-switch)** - Super fast port-speed connection for wide bandwith between Virtual Machines !

* **[IPv6](./IPv6/)** - For now there is not much here since it's hard to get an IPv4 from my ISP.  

* [Enabling VLAN30 access with a Dual-Port 10GbE NIC](./projects/02-vlan30-access-without-sfp-transreceivers)  

## How This Repository Is Organized

This repository is structured to be a clear and useful reference. Here’s a map of the key directories:

*   **`/projects/`**: Probably the most interesting directory cause it's where all project documentations are.
*   **/[device-name]/** (e.g., [`./ccr2004/`](./ccr2004/), [`./r710/`](./r710/)): Contains the latest configuration files and documentation for each piece of hardware. This is the source of truth for device settings.
*   **`/IaC/`**: Holds all Infrastructure as Code projects, primarily using Terraform to automate deployments on Proxmox.
*   **`/docs/`**: Contains details about plans for improving the lab. For example a better addressation plan

## Lab Architecture

### Network Diagram

Here are the diagrams that show the physical and logical topology of my lab.   

#### Physical connections diagram

![physical diagram](./media/physical_diagram.png)

#### Logical topology

![logical diagram](./media/logical_diagram.png)

## Main overview + Plans

My network is oriented towards a datacenter-styled approach because that is the field that I would love to work in.    

I am actively improving things to make this lab as much as possible like a real data center Spine-Leaf Design.   

For now the Spine of my network consists of three routers, a MikroTik CCR2004-1G-12S+2XS, a CRS326-24S+2Q+RM and a VyOS vRouter.
Together, those two physical routers are connected with two eBGP sessions through two 10GbE Fiber links.
I wanted to enable ECMP between them, however, in RouterOS 7.19.4, ECMP for BGP is not supported.   

The CCR2004 has an ASN of 65000, the CRS326 has 65001 and the VyOS vRouter has a 65002 ASN.  

The CCR2004 advertises the default route (`0.0.0.0/0`) to the CRS326 which advertises Networks from it's `BGP_ADV_NET` address list.   

There is also a DHCP Server running on a loopback-like interface on the CCR2004. 
This ensures that it is reachable even when one of the links go down and removes the need for two identical DHCP Servers for two different interfaces, since it's listening on a single bridge.   

From the outside, this network might look pretty small.
However, a lot happens in Proxmox Virtual Environment which runs on my Dell PowerEdge R710.   

In the PVE I run a lot of networking appliances like VyOS and vSRX3 vRouters.   

The PVE is connected through a single DAC 10GbE cable to the CRS326.
This single cable carries a lot of tagged traffic which then gets switched by the main `vmbr0` bridge.  

This way, the inter-VLAN routing between VMs and for example Kubernetes Cluster gets handled by the CRS326 which has enabled L3 Hardware offloading.   

Even though the L3HW offload on CRS326 is fairly simple, as anything above simple routing gets handed to the CPU, it allows for line-speed (10GbE) routing between different VLANs which live on the PVE server.   

That is of course a bit of hairpinning since the traffic goes twice through the same physical cable.   

VLAN segmentation on that link between CRS326 and PVE, allows me to create different logical links without worrying about buying another SFP+ NICs.  

USERS_NET is currently reachable through the point-to-point link between the CRS326 and a VyOS vRouter which also travels through that same DAC Cable but is of course separated with VLAN tagging.   

There is also eBGP session running on the point-to-point link between the CRS326 and the VyOS router.  

USERS_NET Access is available for PCs in another room next to mine via a dual-port RJ45 10GbE NIC which has both its ports bridged onto `vmbr-users`, where also the mentioned VyOS Router has one of it's interfaces.   

This VyOS vRouter is also a DHCP Relay for all devices in USERS_NET.

## Hardware

A list of the key components in my lab. Click a device name to see its configuration files.

| Device Type      | Model                                   | Role in the Lab                                   |
|:---|:---|:---|
| **Server Rack**  | [HPE 10636 G2](./hpe-10636-g2/)         | Central mounting point for all equipment.         |
| **Server**       | [Dell PowerEdge R710](./r710/)          | Main virtualization host, running Proxmox VE.     |
| **Server**       | [Dell PowerEdge R610](./r610/)          | Currently unused, planned for a giveaway.         |
| **Core Router**  | [MikroTik CCR2004](./ccr2004/)           | Core router. Handles routing, firewall and NAT.       |
| **Core Switch**  | [MikroTik CRS326](./crs326/)           | Main switch, inter-VLAN routing handling, L2/L3 switching. |
| **ToR**          | [Dell S4048-ON](.)                     | The most powerful L3 Device in my lab with its Trident 2 ASIC |
| **Switch**| [Brocade FastIron LS648](./ls648/)      | Switch for OOB Management. Handles single L2 domain.     |
| **PDU**          | [HP S1132](./hpe-s1132/)                | Enterprise-grade Power Distribution Unit.                  |

## Projects

This is where the real learning happens. Here are some of the things I’ve built or am currently working on.

### Networking

*   **[OSPF Implementation](./projects/06-ospf-backbone)** - Area 0 between CCR2004 and CRS326   
*   **[Second MTCNA Lab](./projects/08-mtcna-lab-2)** - PPPoE, three CHRs, mini-ISP scenario with clients
*   **[First MTCNA Lab](./projects/07-mtcna-lab-1/readme.md)**
*   **[Addressation modernization, better management](./projects/04-management-network-split)**
*   **[l3 hardware offload instead of router-on-a-stick](./projects/03-l3-hw-offload-on-core-switch)**  
*   **[Repurposing a spare NIC for creating 10GbE VLAN access ports without SFP+ transreceivers](./projects/02-vlan30-access-without-sfp-transreceivers)**

### Active Directory

*   **[First Active Directory scenario](./projects/01-ActiveDirectory-first-scenario)**


### Infrastructure as Code (IaC)

*   **[Terraform RouterOS Wiki LXC](./IaC/terraform_routeros_wiki_lxc/)**: Deploys a local copy of the MikroTik Wiki in an LXC using Terraform.
*   **[Terraform First Deployment](./IaC/terraform_first_deployment/)**: My initial project for deploying a simple CentOS LXC on Proxmox.

### Guides & External Repositories

*   **[Simple VLANs on RouterOS (repo)](https://github.com/andreansx/routeros-simple-vlans)**: A guide to basic VLAN configuration on MikroTik devices.


## Physical Build Log

See how the lab was physically assembled and cabled.

*   **[Server Rack Installation](./installs/installation-rack/)**
*   **[Cabling and Keystone Jack Installation](./installs/installation-keystones/)**

—

## Contact

[![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/Andrtexh)
