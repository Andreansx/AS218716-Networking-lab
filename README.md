# Datacenter networking lab

Here I document everything about my networking lab which serves as a practical ground for learing modern datacenter technologies.     

Currently I'm mainly focused on turning the lab into a datacenter-styled network, particularly I want to create a ultrafast switching fabric in a Clos architecture using my Dell EMC S4048-ON as the spine switch, along with Juniper vQFXs as leaf switches, all connected with eBGP.

<div align=“center”>

![MikroTik](https://img.shields.io/badge/routeros-2B0948?style=for-the-badge&logo=mikrotik&logoColor=white)
![Proxmox](https://img.shields.io/badge/proxmox-542045?style=for-the-badge&logo=proxmox&logoColor=white)
![broadcom](https://img.shields.io/badge/StrataXGS,%20TCAM-7D3742?style=for-the-badge&logo=broadcom&logoColor=white)
![dell](https://img.shields.io/badge/EMC%20OS9-A54E3E?style=for-the-badge&logo=dell&logoColor=white)
![Junos](https://img.shields.io/badge/junos-CE653B?style=for-the-badge&logo=juniper-networks&logoColor=white)

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
4.  [Hardware](#hardware)
5.  [Contact](#contact)

# Docs to read

Here I put things that I think are the most interesting and worth reading.   

These are projects, case studies and troubleshooting logs.    

*   **[Comparative analysis of the purchase of a Dell EMC S4048-ON for the lab instead of other devies](./projects/14-dell-s4048-on-comparative-analysis)**    

*   **[School Network fried by lightning, WiFi fixing, Cisco WLC](./projects/13-school-network/readme.md)** - Very hot topic right now, since my school does not have WiFi available for now. They basically asked me to fix their wifi. I will write here about what things I uncover since it is actually far more complicated than just WiFi.

*   **[eBGP Implementation between two AS'es](./projects/12-eBGP-implementation/readme.md)** - Plus DHCP Nightmare

*   **[Super Important OSPF and L2 Loop troubleshooting](./projects/11-ospf-and-l2-loop/readme.md)** - This is important as it makes some changes to the entire lab archtecture. 

*   **[Finally OSPF Implementation !](./projects/06-ospf-backbone)** - Area 0 between CCR2004 and CRS326   

*   **[Addressation modernization, better management](./projects/04-management-network-split)**

*   **[L3 hardware offload instead of router-on-a-stick](./projects/03-l3-hw-offload-on-core-switch)** - Super fast port-speed connection for wide bandwith between Virtual Machines !

* **[IPv6](./IPv6/)** - For now there is not much here since my ISP does not provide IPv6, and because they use CGNAT, I need to use a Tunnelbroker from Hurricane Electric. But another problem is the lack of a stable IPv4 endpoint.      

* [Enabling VLAN30 access with a Dual-Port 10GbE NIC](./projects/02-vlan30-access-without-sfp-transreceivers)     

# How This Repository Is Organized

This repository is structured to be a clear and useful reference. Here’s a map of the key directories:

*   **`/projects/`**: Probably the most interesting directory cause it's where all project documentations are.
*   **/[device-name]/** (e.g., [`./ccr2004/`](./ccr2004/), [`./r710/`](./r710/)): Contains the latest configuration files and documentation for each piece of hardware. This is the source of truth for device settings.
*   **`/IaC/`**: Holds all Infrastructure as Code projects, primarily using Terraform to automate deployments on Proxmox.
*   **`/docs/`**: Contains details about plans for improving the lab. For example a better addressation plan

# Lab Architecture

## Modernization and currently ongoing

Here is the simplified diagram which shows what I'm making my network to look like.   

![modernization](./media/modernization.png)


## Physical connections diagram

![physical diagram](./media/physical_diagram.png)

## Logical topology

![logical diagram](./media/logical_diagram.png)


## Photos

![devices](./media/devices.jpeg)   

![cables](./media/cables.jpeg)

# Main overview + Plans

> [!NOTE]   
> I re-wrote the overview and plans so I hope they are a bit less messy and are more understandable.   


I would like to divide the description of my network into two main parts: the up-and-running part, and the planned part.   

However, I think the term "planned" might not reflect what I actually mean so here I would like to first write what is running NOW, and by scrolling a bit lower, you can read about what is planned.   
I just want to say that the planned things are not just a "maybe sometime I will do that" thing but rather I have a lot planned out already and I'm just waiting to finish CCNA. 
It's just that even though I'm currently doing CCNA, I did not abandon the lab, and I just stopped more practical implementations and projects, but I am still learning a lot of theory about other things, right now especially TCAM memory blocks and the switching engine blocks and their limitations specifically in Broadcom's StrataXGS series chips.

For now, there are two main network devices running: the MikroTik CCR2004-1G-12S+2XS (AS65000, a.k.a. `border-leaf-ccr2004`), and a CRS326 (AS65001, a.k.a. `leaf-crs326`). 
However, as you probably already noticed, those devices actually are not in a spine-leaf topology.   
Both routers use eBGP for exchanging routing information. 
The CCR2004 advertises the default route to the internet to the CRS326.   
Basically the ccr2004 is a edge router, while the crs326 is a core router.    

The crs326 performs the InterVLAN Routing between the networks in a kind of a router-on-a-stick topology.   
I of course use L3 Hardware offloading on it, since it enables line-speed routing.   

> [!NOTE]   
> Router-on-a-stick from the perspective of the PVE host, not the entire network.   
> Just picture the data flow:    
> Since the SVIs are on the CRS326, the traffic from VM0 (NET20-VMS) to VM1 (NET30-KUBERNETES) first goes from VM0 to the Open vSwitch, then it gets turned into a 802.1q frame with VID 20 and is sent over the tagged link to the CRS326, then the CRS326 performs InterVLAN routing, changes the VID from 20 to 30, and the traffic is sent again through the same link but this time downstream.
> Then the VID is taken off on the Open vSwitch and the untagged 802.3 frame arrives on VM1 vNIC.   


I just want to mention that the "line speed routing" applies mostly only to static routes, and that in serious BGP routing it will punt all the traffic to the CPU.   
I won't get into details here, since I will write a longer document about that sometime, but I just want to say that the chip inside the CRS326 is not an L3 switch chip, even though it might look like it from the documentation.   
It's simply a L2+ chip, which is kinda like typical L2 switch chip, but with some added TCAM memory blocks so it can perform simple longest prefix match L3 lookup, but only for around 36 thousand routes.

There is also a Dell R710 which is a Proxmox Virtual Environment host.
It's running a couple of VyOS VMs, along with a Kubernetes cluster and of course sometimes other Linux VMs.   

It has an upstream connection through a 10GbE link to the CRS326.

That link is separated using VLAN tagging on the CRS326 and the Linux Bridge `vmbr0`, but I will switch to Open vSwitch.   
Thanks to the VLANs, I can create point-to-point connections between VyOS routers, and the CRS326, even though there is only a single physical link.

I think that this is actually everything that is running now.

Below you can read some plans which I would like to implement. 
Sorry for the messy writing, I didn't organize all of that properly, so I will try to re-write all that.   

# Plans

## First thing I want to do is implement OOB-Only Management.    

Currently the network revolves around kind of a "master" network, specifically `10.1.1.0/30`.   
Traffic outgoing from this network, which is attached to `ether1` interface on the CCR2004, is allowed to go everywhere.   

How did I even got the idea to create it like that?   

Well, I thought to myself that, I need to manage networking devices very often, and going to the rack to plug the ethernet cable from the management port to a access port didn't seem very nice.   

So I just combined that two things into a single network, which is obviously a bad practise.    

Also the management network should probably be a single subnet, however in my case it is not, which again is not a good practise.    
The CCR2004 has management interface in `10.1.1.0/30`, while the CRS326 has it in `10.1.1.4/30`.   
This makes it neccessary to use routing, when wanting to access one management interface, from the other one.

I think you can already see how messy this is, even just by reading that and not actually using it.   

The usual setup is to stretch a L2 domain through the devices in the lab.   
For example we create a network NET10-MGMT-VID10, which as you can see in the name, would use VLAN ID of 10.   
Then the process is super simple, cause you just need to add one more allowed VLAN to the tagged links between all devices, and assign an IP address from that network, for each device.   

But that does not work in datacenters, since this kind of management network, is strictly intergrated with the rest of the network, the underlay.   

So I want to completly abandon in-band management and switch to Out-of-band-only management.   
Basically there wll be a network dedicated to management and it will be completely independent of the underlay network.    

Each networking device will simply have one interface with an IP address from that network, and there will be one single simple L2 switch, which will have direct connections to every management interface in the lab.   

One thing I would like to note here is that the management interfaces on the mikrotiks, and on the Dell S4048-ON are very different.   
On my two MikroTik devices, those management ports are basically just an another port, but copper rather than SFP, and with an added "Mgmt" text.

I mean yeah on the CRS326 block diagram, you can see that the `ether1` interface is connected to the CPU rather than to the ASIC, but this is not a carrier-grade control and data plane separation.
The control and data plane would have to be separated also in the software to make any difference.
Without it, when one service glitches, the entire system can glitch, because it is a monolythic system.
That would explain why the part of the network reachable through the ASIC, is actually unaccessable from the `ether1` interface, when L3 Hardware offload is enabled on the ASIC.   

I don't know if that is a feature or a bug, but I tested it a lot of times and it just doesn't work.   

That is another reason to leave the mgmt interfaces for management.    

You may ask "but how to provide Out-of-band management for virtual routers?".   
And that is something I myself was trying to solve, and I got one idea.   

My solution for that is to just create a Linux Bridge/Open vSwitch in the PVE, for example `vmbr-oob`, and bridge one physical interface of the server to it, for example the `eno1` interface.   

Then, when creating, for example, a vQFX VM, just add the Routing Engine's first vNIC (`net0`) to the `vmbr-oob` bridge.   
This way you can have out-of-band management, from a physical switch, for a virtual router, completely indepentend on the main network.

I forgot to mention the Dell EMC S4048-ON.    

It has the best support for OOB Management of all devices in my lab.   
The management interface, which is called `managementethernet1/1`, is literally fully separated from all other interfaces, on the PCB board.   
This, combined with modular Network Operating System, allows for complete separation of data and control plane.   

Even if you exhausted the switching capability of the switch chip, the Management interface is always available and it cannot become congested from the traffic passing through the data plane. 

So the OOB Switch will be the Brocade FLS648.   
It's a piece of junk actually, but I don't need more just for the OOB network.   

The only thing I need from it is to handle a single L2 domain, even without any VLAN tagging etc.   

So the management interface of the Dell S4048-ON will be connected to the FLS648, along with all the other networking devices.   

One important thing is that the management interface should be on the physical port, not on an SVI.
So for example to allow the management of the Dell S4048-ON, I would assign an IP address on the `managementethernet1/1` interface, and that's it.   
I would **not** create an SVI, and add the `managementethernet1/1` as a untagged port for this VLAN.

The OOB Management is after all supposed to be highly available out-of-band.
Using an SVI is another thing which can break, and also it overly complicates the pretty straightforward task of allowing management of the device.   

The out-of-band management interfaces are also important for automatization like Ansible.   
Sometimes things will break and you just would not want to have your only way of accessing the switch cut off.   
If you want to be safe from that, just run Ansible through the management interface, and never let Ansible touch it.  

## Second thing is implementing the Dell EMC S4048-ON switch into the lab.     
writing here
## Third thing is L3-Only network.     
## Hardware

A list of the key components in my lab. Click a device name to see its configuration files.

| Device Type      | Model                                   | Role in the Lab                                   |
|:---|:---|:---|
| **Server Rack**  | [HPE 10636 G2](./hpe-10636-g2/)         | Central mounting point for all equipment.         |
| **PVE Server**       | [Dell PowerEdge R710](./r710/)          | Main virtualization host, running Proxmox VE.     |
| **Border Leaf Router**  | [MikroTik CCR2004](./border-leaf-ccr2004/)           | Border leaf Router, provides access to the internet, NAT, DHCP Server on loopback interface, VPNs and main firewall for North-South traffic       |
| **Leaf Router**  | [MikroTik CRS326](./leaf-crs326/)           | Leaf router. For now handles BGP, inter-VLAN routing with line-speed thanks to L3HW offload | 
| **Spine Switch**          | [Dell S4048-ON](./spine-s4048-on/)  | For now, unused. However, after I finish CCNA, it will become the Spine switch for my network and will handle BGP EVPN, VXLANs and West-East traffic with its astronomic Trident 2 ASIC which TCAM memory I am learning about. |
| **OOB Switch**| [Brocade FastIron LS648](./oob-fls648/)      | Switch for OOB Management. Handles single L2 domain.     |
| **0U PDU**          | [HP S1132](./hpe-s1132/)                | Enterprise-grade Power Distribution Unit.                  |

## Contact

[![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/Andrtexh)
