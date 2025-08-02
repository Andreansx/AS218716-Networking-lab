## L3 Hardware offload on Core switch

What I wanted to achieve is to enable the fastest possible network speed between VLAN 20 and VLAN 40. For now, all inter-VLAN routing was done on the CCR2004 core router with it's CPU. However that is not the perfect scenario, because the CCR2004 is not capable of full interface-speed inter-VLAN routing. That's because all traffic goes through a single SFP transceiver so it divides the overall transfer speed in half. And because the routing is done between VLANs rather than between physical interfaces, it slows down the transfer because of the tagging/untagging process.  

One of the ways to enable faster routing between those two VLANs, is to use **L3 Hardware Offloading**. The MikroTik CRS326 fully supports it.  

The idea was to just change where the routing between VLANs 20 and 40 takes place. 

> [!NOTE]
> For now there seems to be an issue with accessing VLAN 20 when connected to the Management `ether1` port on the CRS326.


## Hardware

*   **Core Router:** MikroTik CCR2004-1G-12S+2XS
*   **Core Switch:** MikroTik CRS326-24S+2Q+RM

# Changing the place of inter-VLAN routing from the Core Router to the Core Switch

First thing that I needed to do was to delete IP addresses from VLANs on the Core Router and assign them on the Core Switch, because now the switch was supposed to be the gateway for them.  

**On the Core Router:**  
```rsc
ip address/
remove [find interface=vlan20-bare-metal]
remove [find interface=vlan40-vms-cts]
```
