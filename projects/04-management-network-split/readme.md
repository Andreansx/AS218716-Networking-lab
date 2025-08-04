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

I will remove the `10.100.10.0/28` network and instead make the `vlan20` network bigger by the previous `vlan10` network.  
The new bare metal network will change from `10.100.10.16/28` to `10.1.2.0/27`. This will enlarge it from 14 usable IPs, to 30 usable IPs.
The `vlan30` network will change from `10.100.30.0/24` to `10.1.3.0/24`, and the `vlan40` network will change from `10.100.40.0/24` to `10.1.4.0/24`.  

### Final plan:

*   **VLAN10** will be removed.

*   **CCR2004, VLAN111:** From `10.1.1.0` to `10.1.1.3` (management: `10.1.1.1/30`)
*   **CRS326, VLAN115:** From `10.1.1.4` to `10.1.1.7` (management: `10.1.1.5/30`)

*   **VLAN20:** From `10.1.2.0` to `10.1.2.31` (gateway: `10.1.2.1/27`) 
*   **VLAN30:** From `10.1.3.0` to `10.1.3.255` (gateway: `10.1.3.1/24`)
*   **VLAN40:** From `10.1.4.0` to `10.1.4.255` (gateway: `10.1.4.1/24`)

*   **inter-router-link0, VLAN100:** From `10.2.1.0` to `10.2.1.3` (CRS326: `10.2.1.2/301`, CCR2004: `10.2.1.1/30`)

## On the CRS326

First I checked how the IPs are assigned:

```rsc
[lynx@core-crs326] /ip/address> export
/ip address
add address=10.100.10.2/28 interface=vlan10-mgmt network=10.100.10.0
add address=10.100.10.17/28 interface=vlan20-bare-metal network=10.100.10.16
add address=10.100.40.1/24 interface=vlan40-vms-cts network=10.100.40.0
```
Then I could get into changing the SVIs addresses and add the management interface
```rsc
[lynx@core-crs326] /ip/address> set [find interface=vlan20-bare-metal] address=10.1.2.1/27
[lynx@core-crs326] /ip/address> set [find interface=vlan40-vms-cts] address=10.1.4.1/24
[lynx@core-crs326] /ip/address> add address=10.1.1.5/30 interface=vlan115-crs326-mgmt
```
Then I checked if those IPs were assigned correctly. For now I left the management network, so it would be easier to change non-critical things first.
```rsc
[lynx@core-crs326] /ip/address> export
/ip address
add address=10.100.10.2/28 interface=vlan10-mgmt network=10.100.10.0
add address=10.1.2.1/27 interface=vlan20-bare-metal network=10.1.2.0
add address=10.1.4.1/24 interface=vlan40-vms-cts network=10.1.4.0
add address=10.1.1.5/30 interface=vlan115-crs326-mgmt network=10.1.1.4
```
Then of course the DHCP relay needs to be updated:
```rsc
[lynx@core-crs326] /ip/dhcp-relay> set [find interface=vlan20-bare-metal] local-address=10.1.2.1   
[lynx@core-crs326] /ip/dhcp-relay> set [find interface=vlan40-vms-cts] local-address=10.1.4.1
```
## On the CCR2004

First I changed all the dhcp-server netowrks
```rsc
[aether@core-ccr2004] /ip/dhcp-server/network> print    
Columns: ADDRESS, GATEWAY, DNS-SERVER
# ADDRESS          GATEWAY       DNS-SERVER  
0 10.100.10.0/28   10.100.10.1   1.1.1.1     
1 10.100.10.16/28  10.100.10.17  10.100.40.99
                                 1.1.1.1     
2 10.100.30.0/24   10.100.30.1   10.100.40.99
                                 1.1.1.1     
3 10.100.40.0/24   10.100.40.1   10.100.40.99
                                 1.1.1.1 
[aether@core-ccr2004] /ip/dhcp-server/network> set 1 address=10.1.2.0/27 gateway=10.1.2.1
[aether@core-ccr2004] /ip/dhcp-server/network> set 2 address=10.1.3.0/24 gateway=10.1.3.1
[aether@core-ccr2004] /ip/dhcp-server/network> set 3 address=10.1.4.0/24 gateway=10.1.4.1
[aether@core-ccr2004] /ip/dhcp-server/network> set [find] dns-server=1.1.1.1
[aether@core-ccr2004] /ip/dhcp-server/network> print
Columns: ADDRESS, GATEWAY, DNS-SERVER
# ADDRESS         GATEWAY      DNS-SERVER
0 10.1.2.0/27     10.1.2.1     1.1.1.1   
1 10.1.3.0/24     10.1.3.1     1.1.1.1   
2 10.1.4.0/24     10.1.4.1     1.1.1.1   
3 10.100.10.0/28  10.100.10.1  1.1.1.1   
```
