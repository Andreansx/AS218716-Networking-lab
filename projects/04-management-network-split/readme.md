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

> [!CAUTION]
> I recently found out that with steps depicted here, the DHCP won't work. Fix is coming so please check out [DHCP Relay fix](../05-dhcp-relay).

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

*   **inter-router-link0, VLAN100:** From `10.2.1.0` to `10.2.1.3` (CRS326: `10.2.1.2/30`, CCR2004: `10.2.1.1/30`)

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
And now a super important step which I forgot at first and then later it caused issues.
Iforgot to add the inter-router link VLAN in the bridge VLAN table.  

It needs to be added and assigned a tagged port.
```rsc
[lynx@core-crs326] /interface/bridge/vlan> add bridge=main-bridge \
tagged=sfp-sfpplus1 vlan-ids=100
```

Management VLAN and the inter-router link interface is set up on the CRS326. Now time to set it up on the CCR2004.  

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

## Creating new routes

Now that everything is set up, I think Im good to go with migrating the routes.

First checking if routers can ping each other through inter-router link.   
On the CCR2004
```rsc
[aether@core-ccr2004] > ping 10.2.1.2
  SEQ HOST                                     SIZE TTL TIME       STATUS
    0 10.2.1.2                                                     timeout
    1 10.2.1.2                                                     timeout
    sent=2 received=0 packet-loss=100%
```
As you can see I wasn't able to ping the CRS326 inter-router link interface.   
This is where the `/interface/bridge/vlan` comes in. 
As you might have seen above, I first forgot to add a tagged port for the `inter-router-link0` VLAN.

The neccessary fix was this:
```rsc
[lynx@core-crs326] /interface/bridge/vlan> add bridge=main-bridge \
tagged=sfp-sfpplus1 vlan-ids=100
```
This ensures that the CRS326 bridge understands the traffic that comes through `sfp-sfpplus1` interface with VLAN tag `100`.  

Now the ping works normally on both the CCR2004 and the CRS326  
```rsc
[aether@core-ccr2004] > ping 10.2.1.2
  SEQ HOST                                     SIZE TTL TIME       STATUS      
    0 10.2.1.2                                   56  64 314us     
    1 10.2.1.2                                   56  64 275us     
    sent=2 received=2 packet-loss=0% min-rtt=275us avg-rtt=294us 
   max-rtt=314us 
```
```rsc
[lynx@core-crs326] > ping 10.2.1.1
  SEQ HOST                                     SIZE TTL TIME       STATUS      
    0 10.2.1.1                                   56  64 835us     
    1 10.2.1.1                                   56  64 420us     
    sent=2 received=2 packet-loss=0% min-rtt=420us avg-rtt=627us 
   max-rtt=835us 
```
Then I added a route for the VLAN 30 through the inter-router link on the CRS326
```rsc
[lynx@core-crs326] /ip/route> print
Flags: D - DYNAMIC; A - ACTIVE; c - CONNECT, s - STATIC; H - HW-OFFLOADED
Columns: DST-ADDRESS, GATEWAY, ROUTING-TABLE, DISTANCE
#      DST-ADDRESS     GATEWAY              ROUTING-TABLE  DISTANCE
0  AsH 0.0.0.0/0       10.100.10.1          main                  1
  DAc  10.1.1.4/30     vlan115-crs326-mgmt  main                  0
  DAcH 10.1.2.0/27     vlan20-bare-metal    main                  0
  DAcH 10.1.4.0/24     vlan40-vms-cts       main                  0
  DAcH 10.2.1.0/30     inter-router-link0   main                  0
  DAcH 10.100.10.0/28  vlan10-mgmt          main                  0
1  AsH 10.100.30.0/24  10.100.10.2          main                  1
[lynx@core-crs326] /ip/route> set 1 dst-address=10.1.3.0/24 \
gateway=10.2.1.1
```

Then on the CCR I set static routes for VLANs 20 and 40  

```rsc
[aether@core-ccr2004] /ip/route> print
Flags: D - DYNAMIC; A - ACTIVE; c - CONNECT, s - STATIC
Columns: DST-ADDRESS, GATEWAY, ROUTING-TABLE, DISTANCE
#     DST-ADDRESS      GATEWAY             ROUTING-TABLE  DISTANCE
0  As 0.0.0.0/0        10.0.0.1            main                  1
  DAc 10.0.0.0/24      sfp-sfpplus12       main                  0
  DAc 10.1.1.0/30      ccr2004-mgmt        main                  0
  DAc 10.1.3.0/24      vlan30-users        main                  0
  DAc 10.2.1.0/30      inter-router-link0  main                  0
  DAc 10.100.10.0/28   ccr2004-mgmt        main                  0
1  As 10.100.10.16/28  10.100.10.2         main                  1
2  As 10.100.40.0/24   10.100.10.2         main                  1
[aether@core-ccr2004] /ip/route> set 1 dst-address=10.1.2.0/27 \
gateway=10.2.1.2
[aether@core-ccr2004] /ip/route> set 2 dst-address=10.1.4.0/24 \
gateway=10.2.1.2
[aether@core-ccr2004] /ip/route> print
Flags: D - DYNAMIC; A - ACTIVE; c - CONNECT, s - STATIC
Columns: DST-ADDRESS, GATEWAY, ROUTING-TABLE, DISTANCE
#     DST-ADDRESS     GATEWAY             ROUTING-TABLE  DISTANCE
0  As 0.0.0.0/0       10.0.0.1            main                  1
  DAc 10.0.0.0/24     sfp-sfpplus12       main                  0
  DAc 10.1.1.0/30     ccr2004-mgmt        main                  0
1  As 10.1.2.0/27     10.2.1.2            main                  1
  DAc 10.1.3.0/24     vlan30-users        main                  0
2  As 10.1.4.0/24     10.2.1.2            main                  1
  DAc 10.2.1.0/30     inter-router-link0  main                  0
  DAc 10.100.10.0/28  ccr2004-mgmt        main                  0
[aether@core-ccr2004] /ip/route> 
```
Then I needed to change the static IP address on my PVE Host, because now it should be in a totally different network.  

The IP change looked something like this since I wasn't able to copy it, because I had to do it with the Console instead of web panel.
```bash
vim /etc/network/interfaces

....
auto vmbr0
iface vmbr0 inet static
    address 10.1.2.30/27 # here i swapped 10.100.10.18/28 with the new IP 
    gateway 10.1.2.1
    bridge ports enp6s0 enp7s0f0 enp7s0f1
    ....

systemctl restart networking
ping 1.1.1.1
64 bytes from 1.1.1.1: icmp_seq=1 ttl=55 time=8.57ms
...
```
I think that it is very cool that I am able to do all that without really messing up my network. Other PC in another room barely felt the change. It even nicely got a 10.1.3.200 IP address from DHCP Server.

I checked on both the CCR2004 and the CRS326 and tried to ping the PC in another room
```rsc
[aether@core-ccr2004] > ping 10.1.3.200
  SEQ HOST                                     SIZE TTL TIME       STATUS      
    0 10.1.3.200                                 56 128 452us     
    1 10.1.3.200                                 56 128 436us     
    2 10.1.3.200                                 56 128 486us     
    sent=3 received=3 packet-loss=0% min-rtt=436us avg-rtt=458us 
   max-rtt=486us 
```
```rsc
[lynx@core-crs326] > ping 10.1.3.200
  SEQ HOST                                     SIZE TTL TIME       STATUS
    0 10.1.3.200                                 56 127 847us
    1 10.1.3.200                                 56 127 886us
    sent=2 received=2 packet-loss=0% min-rtt=847us avg-rtt=866us
   max-rtt=886us
```
Looks like the route to VLAN 30 devices works nicely and the inter-router link replaced the before-used Management network.
```rsc
[lynx@core-crs326] > /tool traceroute 10.1.3.200
ADDRESS                          LOSS SENT    LAST     AVG    BEST   WORST
10.2.1.1                           0%    2   0.3ms     0.4     0.3     0.4
10.1.3.200                         0%    2   0.7ms     0.7     0.7     0.7
```
Then on my laptop plugged with an ethernet cable to `ether1` interface on the CCR2004, I used nmcli to assign myself a static IP from the same subnet that the CCR2004 has a new management interface on.  
```zsh
❯ nmcli con modify 'Połączenie przewodowe 1' ipv4.method manual ipv4.gateway '10.1.1.1' ipv4.address '10.1.1.2/30'
❯ nmcli con down 'Połączenie przewodowe 1'
❯ nmcli con up 'Połączenie przewodowe 1'
❯ ping 10.2.1.2
PING 10.2.1.2 (10.2.1.2) 56(84) bytes of data.
64 bytes from 10.2.1.2: icmp_seq=1 ttl=63 time=0.516 ms
64 bytes from 10.2.1.2: icmp_seq=2 ttl=63 time=0.412 ms
❯ ping 10.1.2.30
PING 10.1.2.30 (10.1.2.30) 56(84) bytes of data.
64 bytes from 10.1.2.30: icmp_seq=1 ttl=62 time=0.333 ms
64 bytes from 10.1.2.30: icmp_seq=2 ttl=62 time=0.246 ms
^C
```
And it looks like I can ping the CRS326 interface on the inter-router link and also my Proxmox VE.  
However I cannot ping `10.1.1.5` which is the CRS326 new management interface. So time to add the correct route on the CCR2004.  
```rsc
[aether@core-ccr2004] /ip/route> add dst-address=10.1.1.4/30 \
gateway=10.2.1.2
[aether@core-ccr2004] /ip/route> print
Flags: D - DYNAMIC; A - ACTIVE; c - CONNECT, s - STATIC
Columns: DST-ADDRESS, GATEWAY, ROUTING-TABLE, DISTANCE
#     DST-ADDRESS     GATEWAY             ROUTING-TABLE  DISTANCE
0  As 0.0.0.0/0       10.0.0.1            main                  1
  DAc 10.0.0.0/24     sfp-sfpplus12       main                  0
  DAc 10.1.1.0/30     ccr2004-mgmt        main                  0
1  As 10.1.1.4/30     10.2.1.2            main                  1
2  As 10.1.2.0/27     10.2.1.2            main                  1
  DAc 10.1.3.0/24     vlan30-users        main                  0
3  As 10.1.4.0/24     10.2.1.2            main                  1
  DAc 10.2.1.0/30     inter-router-link0  main                  0
  DAc 10.100.10.0/28  ccr2004-mgmt        main                  0
```
The route seems to be correct. Now from my laptop with `10.1.1.2` IP address, I can in fact ping the CRS326 new management interface.
```zsh
❯ ping 10.1.1.5
PING 10.1.1.5 (10.1.1.5) 56(84) bytes of data.
64 bytes from 10.1.1.5: icmp_seq=1 ttl=63 time=0.408 ms
64 bytes from 10.1.1.5: icmp_seq=2 ttl=63 time=0.419 ms
```
Now everything seems to be finally coming closer to the end. However I need to change the default route on the CRS326.  
```rsc
[lynx@core-crs326] /ip/route> set 0 gateway=10.2.1.1
[lynx@core-crs326] /ip/route> print
Flags: D - DYNAMIC; A - ACTIVE; c - CONNECT, s - STATIC; H - HW-OFFLOADED
Columns: DST-ADDRESS, GATEWAY, ROUTING-TABLE, DISTANCE
#      DST-ADDRESS     GATEWAY              ROUTING-TABLE  DISTANCE
0  AsH 0.0.0.0/0       10.2.1.1             main                  1
  DAc  10.1.1.4/30     vlan115-crs326-mgmt  main                  0
  DAcH 10.1.2.0/27     vlan20-bare-metal    main                  0
1  AsH 10.1.3.0/24     10.2.1.1             main                  1
  DAcH 10.1.4.0/24     vlan40-vms-cts       main                  0
  DAcH 10.2.1.0/30     inter-router-link0   main                  0
  DAcH 10.100.10.0/28  vlan10-mgmt          main                  0
```
Looks like now the network is ready for the clean-up. 
I will delete old Management network, and since `/tool traceroute` already showed that all traffic is already going through the inter-router link, there shouldn't be any more issues.

I changed the IPs from old ones to correct new ones in my `.ssh/config` file.  

After changing the IPs in the config file, I of course had to accept new fingerprints, but seems like I was able to fully log into the CRS326 on it's new management interface (`10.1.1.5`) from my laptop (`10.1.1.2`) plugged into `ether1` on the CCR2004.  

Then just in case I used Safe Mode on the CRS326 and deleted the old management interface IP address.
```rsc
[lynx@core-crs326] >
Taking Safe Mode session... Success!
[lynx@core-crs326] <SAFE> ip address/remove [find interface=vlan10-mgmt]
```
There was not even any slight hiccup so I can go forward with fully deleting vlan 10.  
I also need to add `ether1` as a untagged port on the CRS326 for the VLAN 115. 
This will act as a saftety measure if something sometime went wrong with remote access.  

```rsc
[lynx@core-crs326] /interface/bridge/vlan> set [find vlan-ids=115] \
untagged=ether1
[lynx@core-crs326] /interface/bridge/vlan> remove [find vlan-ids=10]
[lynx@core-crs326] /interface/vlan> remove [find vlan-id=10]
```
Now I fully removed the old VLAN 10. 
I need also to correct the `dhcp-server` in DHCP Relay configuration on the CRS326.
```rsc
[lynx@core-crs326] /ip/dhcp-relay> set [find dhcp-server=10.100.10.1] dhcp-server=10.2.1.1
```
This adds the CCR2004 inter-router link interface as the one that will handle DHCP requests.
And since the CCR2004 already has DHCP server running on the trunk port, even though there is no IP address on them, it has all those VLANs (20,30,40) still on the `sfp-sfpplus1` interface.   

There doesn't seem to be much work to do anymore on the CRS326, so time to get back to the CCR2004.  

On the CCR2004 I can also fully delete the old VLAN 10.  
```rsc
[aether@core-ccr2004] /interface/vlan> remove [find vlan-id=10]
[aether@core-ccr2004] /ip/pool> remove [find name=pool-management]
[aether@core-ccr2004] /ip/address> remove numbers=1
[aether@core-ccr2004] /ip/dhcp-server> remove [find interface=ccr2004-mgmt]
[aether@core-ccr2004] /ip/firewall/address-list> remove \
[find list=management]
[aether@core-ccr2004] /ip/dhcp-server/network> remove \
[find gateway=10.100.10.1]
```

Looks like the network is fully migrated to a better addressation and a better management!  

Now the only thing left is to redo the firewall.  

I thought it would be actually easier to remake all firewall rules instead of modyfying them.  

However, this time I wil use a combination of interface and address lists instead of only address lists.  

This way is more elastic and scalable, beacause it operates on interfaces and not only addresses. 
For exmaple, a SVI IP can change but the firewall rule is tied to the VLAN interface and not to the specific IP.  

First I created zones on the CCR2004
```rsc
[aether@core-ccr2004] /interface/list> add name=ZONE-USERS
[aether@core-ccr2004] /interface/list> add name=ZONE-CCR2004-MGMT
[aether@core-ccr2004] /interface/list> add name=ZONE-WAN
[aether@core-ccr2004] /interface/list> add name=LINK-TO-CRS326
```
Then I added interfaces to those zones
```rsc
[aether@core-ccr2004] /interface/list/member> add list=ZONE-USERS \
interface=vlan30-users 
[aether@core-ccr2004] /interface/list/member> add list=ZONE-WAN \
interface=sfp-sfpplus12 
[aether@core-ccr2004] /interface/list/member> add list=ZONE-CCR2004-MGMT \
interface=ccr2004-mgmt 
[aether@core-ccr2004] /interface/list/member> add list=LINK-TO-CRS326 \
interface=inter-router-link0 
```
Then I added address lists.
```rsc
[aether@core-ccr2004] /ip/firewall/address-list> add \
address=10.1.1.4/30 list=CRS326-MGMT
[aether@core-ccr2004] /ip/firewall/address-list> add \
address=10.1.2.0/27 list=SERVERs-NET
[aether@core-ccr2004] /ip/firewall/address-list> add \
address=10.1.4.0/24 list=VMs/LXCs-NET
```
Below are firewall rules for the CCR2004. 
There was a lot of moving them around so I am here placing them in a final version.   


Allowing all established connections
```rsc
/ip firewall filter
add action=accept chain=input connection-state=established,related
add action=accept chain=forward comment=\
    "Allowing already established connections" connection-state=\
    established,related
```
Allowing all traffic from CCR2004 Management
```rsc
add action=accept chain=input in-interface-list=ZONE-CCR2004-MGMT
```
Allowing ICMP from networks behind inter-router link to CRS326
```rsc
add action=accept chain=input in-interface-list=LINK-TO-CRS326 protocol=icmp
```
Allowing CCR2004 Management to access networks behind inter-router link and the users VLAN.
```rsc
add action=accept chain=forward dst-address-list=SERVERs-NET,VMs/LXCs-NET \
    in-interface-list=ZONE-CCR2004-MGMT out-interface-list=LINK-TO-CRS326
add action=accept chain=forward in-interface-list=ZONE-CCR2004-MGMT \
    out-interface-list=ZONE-USERS
```
Allowing the CCR2004 Management to access CRS326 Management interface
```rsc
add action=accept chain=forward comment=\
    "Accept traffic between CCR2004 Management and CRS326 Management" \
    dst-address-list=CRS326-MGMT in-interface-list=ZONE-CCR2004-MGMT \
    out-interface-list=LINK-TO-CRS326 port=22,8291 protocol=tcp
```
Blocking users from accessing anything thats behind the inter-router link to CRS326.
```rsc
add action=drop chain=forward comment=\
    "Block traffic from users to networks behind CRS326" in-interface-list=\
    ZONE-USERS out-interface-list=LINK-TO-CRS326
```
Allowing all networks to access the internet
```rsc
add action=accept chain=forward in-interface-list=ZONE-USERS \
    out-interface-list=ZONE-WAN
add action=accept chain=forward in-interface-list=LINK-TO-CRS326 \
    out-interface-list=ZONE-WAN
add action=accept chain=forward in-interface-list=ZONE-CCR2004-MGMT \
    out-interface-list=ZONE-WAN
```
Denying all other traffic by default
```rsc
add action=drop chain=input
add action=drop chain=forward comment="Dropping all other forward traffic"
```

Now just a simple firewall rule for the other router.  

The CRS326 handles inter-VLAN routing between VLANs 20 and 40, so it has to know to not let them access it's management VLAN.  

```rsc
/ip firewall filter
add action=drop chain=input dst-address-list=CRS326-MGMT src-address-list=\
    SERVERs,VMs/LXCs
```

Seems like everything is done.
