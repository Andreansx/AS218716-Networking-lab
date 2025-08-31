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

# Actual plans

For now there are a couple of things that I really want to do.   

First thing is to implement distributed routing between VMs Nets with virtual **vSRX3** routers.   
Now, the VMs nets are routed with inter-VLAN routing between CRS326's SVIs in those VLANs which are directly connected to the CRS326 through a tagged link for VLANs 20,40,50 and 108 (108 is point-to-point link to VyOS vRouter. this is a first step into the distributed routing).   
However, I want to make it that so the CRS326 does not have a direct connection to the VLANs.  
It will only have direct connection to a couple of vSRX3 vRouters and the VLANs for VMs etc. would be reachable only through an appropriate vSRX3 router in the PVE.   
And here I can get into the second thing.   

In order to make this really elegant and elastic, I will be changing my network to be a L3-Only architecture. 
This means that the CRS326 will be one AS, CCR2004 will be another AS, Dell S4048-ON will be another and each of the vSRX3 routers will also be a separate AS.   

This brings me to another thing, which is VXLAN implementation.  

This L3-Only network is exactly what is needed for VXLAN with EVPN for BGP implementation.  

The vSRX3 vRouters will be (if needed) some of the VTEPS, and for example the CRS326 will be another VTEP.  
This way, there is a great underlay L3 network for BGP EVPN which would allow me to connect a physical device to the CRS326, add it to a VLAN and bind a VNI to the VID. 
And then I could allow this device to communicate with, for example VMs in the VMs Net like they were in the same L2 domain. 
But in reality they would be connected by a overlay L2 network which works over an L3 underlay network where BGP EVPN works to provide better routes between the VTEPs, instead of "flood-and-learn".    


For now, I want to just attach this Dell EMC S4048-ON switch into the network.  
I need to plan a little bit more on how to change the architecture of my network, since I want to use the Dell EMC switch as a **ToR** switch.  


## How This Repository Is Organized

This repository is structured to be a clear and useful reference. Here’s a map of the key directories:

*   **/[device-name]/** (e.g., [`./ccr2004/`](./ccr2004/), [`./r710/`](./r710/)): Contains the latest configuration files and documentation for each piece of hardware. This is the source of truth for device settings.
*   **`/IaC/`**: Holds all Infrastructure as Code projects, primarily using Terraform to automate deployments on Proxmox.
*   **`/docs/`**: Contains details about plans for improving the lab. For example a better addressation plan
*   **`/projects/`**: Probably the most interesting directory cause it's where all project documentations are.

## Lab Architecture

### Network Diagram

Here are the diagrams that show the physical and logical topology of my lab.   

#### Physical connections diagram

![physical diagram](./media/physical_diagram.png)

## Key Features

Below is a descrition of how generally my lab is built.  

The network consists of two main Routers, both connected with two eBGP sessions.   
*   **CCR2004-1G-12S+2XS** - This incredibly powerful router handles DHCP Server on loopback bridge, NAT, Stateful firewall etc.
*   **CRS326-24S+2Q+RM** - Super powerful switch with L3 Hardware offload onto the ASIC. Handles most of inter-VLAN Routing.  

It's also a DHCP Relay for VLANs 20, 40 and 50.  
Both of those routers are connected through a pair of p2p links where eBGP is running.
Each of them has a separate, small `/30` network for management.  

> [!IMPORTANT]
> For now, the Inter-VLAN Routing between VLANs 30,40,50 etc. is handled by the CRS326. However, that will change. 
> I will remove the VLANs 30,40,50 SVIs from the CRS326 and instead add them on three separate vSRX3 virtual Routers. The CRS326 will still handle routing between those VLANs but this is a step in the direction of a distributed routing.
> VMs traffic could actually not even leave the Proxmox Host. For example, routing between network 40 (VMs/LXCs) and network 50 (kubernetes) could be handled fully by vSRX3 router.    
> However, that would actually be slower than inter-VLAN routing on my physical router CRS326 since it's ASIC is more powerful than software routing on the Dell R710.
> The VLANs 30,40,50 would be available only through inter-router links between the CRS326 and the vSRX3 routers on the PVE host.

The main Server in my lab is a Dell PowerEdge R710. It's running Proxmox VE and it's equipped with 1x 10GbE SFP+ NIC, and another 2x 10GbE RJ45 NIC.  

The SFP+ 10GbE NIC provides the main uplink from the server to the CRS326. This physical interface is added to the `vmbr0` bridge and carries tagged traffic for VLANs 20,40,50 and 108.   

The RJ45 10GbE dual-port NIC physical ports are added to the `vmbr1` bridge. The `VyOS-VL3` has an interface `net1` on this bridge with an IP address of 10.1.3.1/24.   

This provides access to the network through Cat6A cable runs from the NIC, through the wall, into another room.   

VLAN 30 is reachable through the CRS326, through a inter-router link (VLAN 108) to the VyOS-VL3 VM.



## VLAN & IP Schema

The network is separated using VLANs.

| ID  & Name    | Network | Where | Description                                   |
|:---|:---|:---|:---|
| 20 - Bare Metal | 10.1.2.0/27         | SVI on Core-CRS326 | Here are bare-metal devices. For example, the PVE Host is here on 10.1.2.30/27.        |
| 30 - Users | 10.1.3.0/24         | SVI on VyOS-VL3 | This is the VLAN in which all devices in another room will be connected to    |
| 40 - VMs/LXCs | 10.1.4.0/24       | SVI on Core-CRS326  | Here are placed Virtual Machines accessible through `vmbr0` |
| 50 - Kubernetes | 10.1.5.0/27       | SVI on Core-CRS326  | Dedicated separate network for "public" IPs for the nodes in kubernetes cluster. |
| 60 - OOB     | 10.1.6.0/24      | ....     | As now the network is evolving, I will be going in the direction of OOB-Only Management cause that is how management is actually handled in Data Centers |


There are also two networks dedicated for Kubernetes cluster internal IPs   

*   **Services CIDR** - `10.5.0.0/16`
*   **Cluster CIDR** - `10.6.0.0/16`


There are also dedicated VLANs for management and traffic tranzit.

*   **VLAN 100** - This is the VLAN used for the `eBGP-Link-0` interfaces on the main routers. 
    CCR2004 - `172.16.255.1/30`
    CRS326  - `172.16.255.2/30`
*   **VLAN 104** - Another link for eBGP session. Here are the `eBGP-Link-1` interfaces of the main routers.
    CCR2004 - `172.16.255.5/30`
    CRS326  - `172.16.255.6/30`
*   **VLAN 108** - Inter-Router link between the CRS326 and the VyOS-VL3 which makes the VLAN 30 reachable through the VyOS virtual Router.
    VyOS-VL3 - `172.16.255.10/30`
    CRS326  - `172.16.255.9/30`
*   **VLAN 111** - This is where the management SVI for the CCR2004 is. The CCR2004 has a `10.1.1.1/30` IP here.
*   **VLAN 115** - Here is the management SVI for the CRS326 with `10.1.1.5/30` IP Address.

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
