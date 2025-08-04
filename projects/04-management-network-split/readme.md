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

> [!NOTE]
> As you will see below, I am not changing the VLAN 10 addresses etc. That is because I don't need to. In fact this is also a sefety measure bacause I can in fact add two management interfaces at the same time. The fact that I am leaving the VLAN 10 network enabled, makes sure that if something goes wrong with the inter-router link or the new management interfaces, I will still be able to access those devices.

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
Then also IP pools
```rsc
[aether@core-ccr2004] /ip/pool> print
Columns: NAME, RANGES, TOTAL, USED, AVAILABLE
#  NAME             RANGES                       TOTAL  USED  AVAILABLE
0  pool-management  10.100.10.3-10.100.10.14        12     1         11
1  pool-bare-metal  10.100.10.19-10.100.10.30       12     0         12
2  pool-users       10.100.30.100-10.100.30.200    101     1        100
3  pool-vms-cts     10.100.40.100-10.100.40.200    101     0        101
[aether@core-ccr2004] /ip/pool> set 1 ranges=10.1.2.2-10.1.2.30
[aether@core-ccr2004] /ip/pool> set 2 ranges=10.1.3.50-10.1.3.200
[aether@core-ccr2004] /ip/pool> set 3 ranges=10.1.4.50-10.1.4.200
[aether@core-ccr2004] /ip/pool> print
Columns: NAME, RANGES, TOTAL, USED, AVAILABLE
#  NAME             RANGES                    TOTAL  USED  AVAILABLE
0  pool-management  10.100.10.3-10.100.10.14     12     1         11
1  pool-bare-metal  10.1.2.2-10.1.2.30           29     0         29
2  pool-users       10.1.3.50-10.1.3.200        151     1        150
3  pool-vms-cts     10.1.4.50-10.1.4.200        151     0        151
```
And firewall ip lists
```rsc
[aether@core-ccr2004] /ip/firewall/address-list> print
Columns: LIST, ADDRESS, CREATION-TIME
# LIST        ADDRESS          CREATION-TIME
0 management  10.100.10.0/28   2025-07-02 11:32:42
1 bare-metal  10.100.10.16/28  2025-07-02 11:32:42
2 users       10.100.30.0/24   2025-07-02 11:32:42
3 vms-cts     10.100.40.0/24   2025-07-02 11:32:42
[aether@core-ccr2004] /ip/firewall/address-list> set 1 address=10.1.2.0/27
[aether@core-ccr2004] /ip/firewall/address-list> set 2 address=10.1.3.0/24
[aether@core-ccr2004] /ip/firewall/address-list> set 3 address=10.1.4.0/24
```
I went back to CRS326   

For the VLAN 115, there does not have to be any tagged ports. Since this is just a SVI for management.

I created the inter-router link:

```rsc
[lynx@core-crs326] /interface/vlan> add interface=main-bridge \
name=inter-router-link0 vlan-id=100
[lynx@core-crs326] /ip/address> add interface=inter-router-link0 \
address=10.2.1.2/30
```

Management VLAN is set up on the CRS326. Now time to set it up on the CCR2004.  

> [!IMPORTANT]
> Below, I am adding the IP interface not on the SVI, but rather on the bridge. From what I know this is a better and more elastic way of doing this. Now if something with the VLAN went wrong, the IP is on the bridge and not on the SVI itself. The `ccr2004-mgmt` bridge is simply a "dumb" switch that connects `ether1` port with the SVI 111. And now it will be possible to access `10.1.1.1/30` Management interface both through `ether1` and through the VLAN 111.

Another important thing is the correct way of connecting a VLAN to a bridge.  
My first attempt was like this:
```rsc
[aether@core-ccr2004] /interface/vlan> add vlan-id=111 \
name=vlan111-ccr2004-mgmt interface=br-mgmt
```
However this is dead wrong, because now the VLAN is in fact added on the bridge. 
But it does not have any connection to outside.   

Correct way is by adding the VLAN to the bridge through `/interface/bridge/port. Just like adding a physical interface to a bridge.
This below is the correct way:
```rsc
[aether@core-ccr2004] /interface/vlan> add interface=sfp-sfpplus1 \
vlan-id=111 name=vlan111-ccr2004-mgmt
[aether@core-ccr2004] /interface/bridge/port> add bridge=ccr2004-mgmt \ 
interface=vlan111-ccr2004-mgmt 
```

Then the IP address for the SVI 111

```rsc
[aether@core-ccr2004] /ip/address> add address=10.1.1.1/30 \ interface=br-mgmt
```
Next the inter-router link and assigning a IP for it.

As you can see, now the CCR2004 and CRS326 will have two direct connections. As I mentioned above, this is to make the modernization safer. I am simply leaving it in case something goes wrong.

```rsc
[aether@core-ccr2004] /interface/vlan> add vlan-id=100 \
name=inter-router-link0 interface=sfp-sfpplus1
[aether@core-ccr2004] /ip/address> add address=10.2.1.1/30 \
interface=inter-router-link0 
```
Then I checked and surely new dynamic routes appeared in the routing table:
```rsc
[aether@core-ccr2004] /ip/route> print
Flags: D - DYNAMIC; A - ACTIVE; c - CONNECT, s - STATIC
Columns: DST-ADDRESS, GATEWAY, ROUTING-TABLE, DISTANCE
#     DST-ADDRESS      GATEWAY               ROUTING-TABLE  DISTANCE
0  As 0.0.0.0/0        10.0.0.1              main                  1
  DAc 10.0.0.0/24      sfp-sfpplus12         main                  0
  DAc 10.1.1.0/30      vlan111-ccr2004-mgmt  main                  0
  DAc 10.1.3.0/24      vlan30-users          main                  0
  DAc 10.2.1.0/30      inter-router-link0    main                  0
  DAc 10.100.10.0/28   br-mgmt               main                  0
1  As 10.100.10.16/28  10.100.10.2           main                  1
2  As 10.100.40.0/24   10.100.10.2           main                  1
```
Routes 1 and 2 are static routes I manually assigned so they still have old VLAN addresses assigned to them. I will of course change them.  

It's also really nice that I can already see new dynamic routes that appeared. Those are only direct connections for now cause I need to set up new routes.

> [!NOTE]
> Next step after this project will be to delete static routes and implement OSPF dynamic routing. But for now I will set up static routes.

