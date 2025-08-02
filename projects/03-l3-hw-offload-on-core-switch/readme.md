## L3 Hardware offload on Core switch

What I wanted to achieve is to enable the fastest possible network speed between VLAN 20 and VLAN 40. For now, all inter-VLAN routing was done on the CCR2004 core router with it's CPU. However that is not the perfect scenario, because the CCR2004 is not capable of full interface-speed inter-VLAN routing. That's because all traffic goes through a single SFP transceiver so it divides the overall transfer speed in half. And because the routing is done between VLANs rather than between physical interfaces, it slows down the transfer because of the tagging/untagging process.  

One of the ways to enable faster routing between those two VLANs, is to use **L3 Hardware Offloading**. The MikroTik CRS326 fully supports it.  

The idea was to just change where the routing between VLANs 20 and 40 takes place. 

> [!IMPORTANT]
> For now there seems to be an issue with accessing VLAN 20 when connected to the Management `ether1` port on the CRS326. Although when plugged into `ether1` on the CCR2004, there doesn't seem to be any issue.


## Hardware

*   **Core Router:** MikroTik CCR2004-1G-12S+2XS
*   **Core Switch:** MikroTik CRS326-24S+2Q+RM

# Changing the place of inter-VLAN routing from the Core Router to the Core Switch

First thing that I needed to do was to delete IP addresses from VLANs on the Core Router and assign them on the Core Switch, because now the switch was supposed to be the gateway for them.  

> [![NOTE]]
> For now, the route that will be used for communicating with VLANs is through 10.100.10.0/28, since this is the network where both devices have a IP address on the management interface. 
> Because of the fact that those devices have a direct connection through 10.100.10.0/28, adding an inter-router link is pointless, since it will have lower priotity than the direct connection route. I will split the management IP addresses so those devices will not have a direct connection on the management interface, and instead will communicate through a inter-router link.

### On the Core Router  

```rsc
ip address/
remove [find interface=vlan20-bare-metal]
remove [find interface=vlan40-vms-cts]
```

Next, I had to ensure that the Core Router will know through where to route traffic for accessing VLANs 20 and 40, since it now does not have any IP addresses on them, because the CRS326 will be the gateway for those VLAMs.  

```rsc
ip route
# This routes the traffic designated to vlan 20 and 40 through management interface of core switch
add dst-address=10.100.10.16/28 gateway=10.100.10.2
add dst-address=10.100.40.0/24 gateway=10.100.10.2
```
The routing table would look like this:
```rsc
[aether@core-ccr2004] > ip route/print
Flags: D - DYNAMIC; A - ACTIVE; c - CONNECT, s - STATIC
Columns: DST-ADDRESS, GATEWAY, ROUTING-TABLE, DISTANCE
#     DST-ADDRESS      GATEWAY                  ROUTING-TABLE  DISTANCE
0  As 0.0.0.0/0        10.0.0.1                 main                  1
  DAc 10.0.0.0/24      sfp-sfpplus12            main                  0
  DAc 10.100.10.0/28   br-mgmt                  main                  0
1  As 10.100.10.16/28  10.100.10.2              main                  1
  DAc 10.100.30.0/24   vlan30-users             main                  0
  DAc 10.100.50.0/28   vlan50-active-directory  main                  0
```

**As mentioned above,** this is not a good practise. But as I stated above, I will create a inter-router link for this traffic instead of it going through management network.  

I left the dhcp servers on the VLAN interfaces even though there is no IP address configured on either VLAN 20 or VLAN 40. However, this does not seem to cause any issue as of now.  

### On the core switch  

First I had to create gateways for the VLANs 20 and 40 on the CRS326 like this:
```rsc
/ip address
add address=10.100.10.17/28 interface=vlan20-bare-metal
add address=10.100.40.1/24 interface=vlan40-vms-cts
```

The gateway can be left as it was, for now.
```rsc
/ip route
add gateway=10.100.10.1
```
I then turned on the L3 Hardware offloading for the switch1 (ASIC)
```rsc
/interface/ethernet/switch
print
Columns: NAME, TYPE, L3-HW-OFFLOADING, QOS-HW-OFFLOADING
# NAME     TYPE              L3-HW-OFFLOADING  QOS-HW-OFFLOADING
0 switch1  Marvell-98DX8332  no               no               
1 switch2  Atheros-8227      no                no               

set 0 l3-hw-offloading=yes
```
