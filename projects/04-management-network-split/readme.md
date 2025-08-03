# Network modernization

> [!IMPORTANT]
> Check related documents: **[ip-plan-v3](../../docs/ip-plan-v3.md)**, **[L3 HW Offload](../03-l3-hw-offload-on-core-switch)**   

> [!NOTE]
> Wherever I use the "SVI (ID here)", I mean **Switched Virtual Interface with the following VLAN ID**  

This document covers the process of modernizing my network, mainly by splitting the Management VLAN into super-small dedicated networks.  
This will provide a great backbone for next step, which is implementing OSPF dynamic routing and a kind of OOB Management.   

Each network device such as the CCR2004 Core Router, will have it's own `/30` network dedicated to providing access to management features. This solves the issue of the Management network becoming the highest priority route for VLANs.   

Usually, none of this would happen in a casual router-on-a-stick topology. 
However, because of the L3 Hardware offload implementation on the CRS326 along with making it the gateway for VLANs 20 and 40 instead of letting the CCR2004 handle all inter-VLAN routing, this topology gets more advanced and I need to add the correct separation of the Control and Data Planes.  

## Addresses

Here is a brief overview on how I will change the addresses:   

*   **CCR2004:** New management interface on SVI 111 (`10.1.1.1/30`)
*   **CRS326:** Management interface on SVI 115 (`10.1.1.5/30`)

As mentioned above, in the related documents, the CRS326 and CCR2004 will have their management IPs on the SVIs. 
My first idea regarding the CRS326, was to assign the Management IP on the `ether1` interface.  

However, that would make the remote management of it impossible, as interfaces handled by two different chips with L3 Hw offload enabled on one of them, cannot talk to each other properly when routing is neccessary. 
