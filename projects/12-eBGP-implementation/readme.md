# eBGP for the core

What this document covers are the steps I took in effort to swap OSPFv2 Area 0 for eBGP session between my two core routers.

> [!IMPORTANT]
> This is gonna be a really big documentation. There is a lot to write but I will try to group the steps in some way even though in reality this was super messy. Swapping routes for BGP routes was not complex in itself but there is a lot of other things that are important.  
> I think it's best to first read a couple of documentations:  
> [OSPF and Loop troubleshooting](../11-ospf-and-l2-loop/readme.md)  
> [OSPF Backbone](../06-ospf-backbone/readme.md)

# Environment

*   **CCR2004-1G-12S+2XS**
    *   RouterOS version: v7.19.4
    *   Connections:
        *   `sfp-sfpplus1` - link to `sfp-sfpplus1` on CRS326
        *   `sfp-sfpplus11` - link to `sfp-sfpplus24` on CRS326
        *   `ether1` - management
        *   `sfp-sfpplus12` - link to ISP Router
    *   Config:

<details>
    <summary><h2>CCR2004-config.rsc</h2></summary>
    
```rsc
/interface bridge
add name=ccr2004-mgmt port-cost-mode=short
add name=loopback0
/interface bonding
add mode=802.3ad name=bond0 slaves=sfp-sfpplus1,sfp-sfpplus11 \
    transmit-hash-policy=layer-2-and-3
/interface vlan
add interface=bond0 name=inter-router-link0 vlan-id=100
add interface=bond0 name=vlan111-ccr2004-mgmt vlan-id=111
/interface list
add name=ZONE-USERS
add name=ZONE-CCR2004-MGMT
add name=ZONE-WAN
add name=LINK-TO-CRS326
/interface lte apn
set [ find default=yes ] ip-type=ipv4 use-network-apn=no
/ip pool
add name=pool-bare-metal ranges=10.1.2.2-10.1.2.29
add name=pool-users ranges=10.1.3.50-10.1.3.200
add name=pool-vms-cts ranges=10.1.4.50-10.1.4.200
add name=pool-kubernetes ranges=10.1.5.2-10.1.5.30
/ip dhcp-server
add address-pool=pool-users interface=inter-router-link0 lease-time=5d name=\
    dhcp-users relay=10.1.3.1
add address-pool=pool-vms-cts interface=inter-router-link0 lease-time=5d \
    name=dhcp-vlan40 relay=10.1.4.1
add address-pool=pool-bare-metal interface=inter-router-link0 lease-time=5d \
    name=dhcp-vlan20 relay=10.1.2.1
add address-pool=pool-kubernetes interface=inter-router-link0 lease-time=1w3d \
    name=dhcp-kubernetes relay=10.1.5.1
/port
set 0 name=serial0
/routing ospf instance
add disabled=no name=backbonev2 router-id=172.16.0.1
/routing ospf area
add disabled=no instance=backbonev2 name=backbone0v2
/interface bridge port
add bridge=ccr2004-mgmt comment="access for laptop" ingress-filtering=no \
    interface=ether1 internal-path-cost=10 path-cost=10
add bridge=ccr2004-mgmt interface=vlan111-ccr2004-mgmt
/interface list member
add interface=*14 list=ZONE-USERS
add interface=sfp-sfpplus12 list=ZONE-WAN
add interface=ccr2004-mgmt list=ZONE-CCR2004-MGMT
add interface=inter-router-link0 list=LINK-TO-CRS326
/ip address
add address=10.0.0.150/24 comment=WAN interface=sfp-sfpplus12 network=\
    10.0.0.0
add address=10.1.1.1/30 interface=ccr2004-mgmt network=10.1.1.0
add address=172.16.255.1/30 interface=inter-router-link0 network=172.16.255.0
add address=172.16.0.1 interface=loopback0 network=172.16.0.1
/ip dhcp-server lease
add address=10.1.5.30 mac-address=BC:24:11:80:55:00
add address=10.1.5.29 mac-address=BC:24:11:80:55:01
add address=10.1.5.28 mac-address=BC:24:11:80:55:02
/ip dhcp-server network
add address=10.1.2.0/27 dns-server=1.1.1.1 gateway=10.1.2.1
add address=10.1.3.0/24 dns-server=1.1.1.1 gateway=10.1.3.1
add address=10.1.4.0/24 dns-server=1.1.1.1 gateway=10.1.4.1
add address=10.1.5.0/27 dns-server=1.1.1.1,8.8.8.8 gateway=10.1.5.1
/ip dns
set servers=10.1.4.20,1.1.1.1
/ip firewall address-list
add address=10.1.1.4/30 list=CRS326-MGMT
add address=10.1.2.0/24 list=SERVERs-NET
add address=10.1.4.0/24 list=VMs/LXCs-NET
add address=10.1.5.0/27 list=Kubernetes-NET
/ip firewall filter
add action=accept chain=input connection-state=established,related
add action=accept chain=forward comment=\
    "Allowing already established connections" connection-state=\
    established,related
add action=accept chain=input in-interface-list=ZONE-CCR2004-MGMT
add action=accept chain=input in-interface-list=LINK-TO-CRS326 protocol=icmp
add action=accept chain=input in-interface-list=LINK-TO-CRS326 protocol=ospf
add action=accept chain=forward dst-address-list=SERVERs-NET \
    in-interface-list=ZONE-CCR2004-MGMT out-interface-list=LINK-TO-CRS326
add action=accept chain=forward dst-address-list=VMs/LXCs-NET \
    in-interface-list=ZONE-CCR2004-MGMT out-interface-list=LINK-TO-CRS326
add action=accept chain=forward dst-address-list=Kubernetes-NET \
    in-interface-list=ZONE-CCR2004-MGMT out-interface-list=LINK-TO-CRS326 \
    port=22 protocol=tcp
add action=accept chain=forward dst-address-list=Kubernetes-NET \
    in-interface-list=ZONE-CCR2004-MGMT out-interface-list=LINK-TO-CRS326 \
    protocol=icmp
add action=accept chain=forward dst-address-list=Kubernetes-NET \
    in-interface-list=ZONE-CCR2004-MGMT out-interface-list=LINK-TO-CRS326
add action=accept chain=forward in-interface-list=ZONE-CCR2004-MGMT \
    out-interface-list=ZONE-USERS
add action=accept chain=forward comment=\
    "Accept traffic between CCR2004 Management and CRS326 Management" \
    dst-address-list=CRS326-MGMT in-interface-list=ZONE-CCR2004-MGMT \
    out-interface-list=LINK-TO-CRS326 port=22,8291 protocol=tcp
add action=drop chain=forward comment=\
    "Block traffic from users to networks behind CRS326" in-interface-list=\
    ZONE-USERS out-interface-list=LINK-TO-CRS326
add action=accept chain=forward in-interface-list=ZONE-USERS \
    out-interface-list=ZONE-WAN
add action=accept chain=forward in-interface-list=LINK-TO-CRS326 \
    out-interface-list=ZONE-WAN
add action=accept chain=forward in-interface-list=ZONE-CCR2004-MGMT \
    out-interface-list=ZONE-WAN
add action=drop chain=input
add action=drop chain=forward comment="Dropping all other forward traffic"
/ip firewall nat
add action=masquerade chain=srcnat out-interface=sfp-sfpplus12
/ip route
add disabled=no dst-address=0.0.0.0/0 gateway=10.0.0.1
add dst-address=10.1.1.4/30 gateway=172.16.255.2
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
/routing ospf interface-template
add area=backbone0v2 disabled=no networks=172.16.0.1/32 passive
add area=backbone0v2 disabled=no networks=172.16.255.0/30
/system clock
set time-zone-name=Europe/Warsaw
/system identity
set name=core-ccr2004
/system resource irq rps
set ether1 disabled=no
```

</details>


# Why even doing this?

So first I would like to explain why actually I even wanted to swap the OSPF Area 0 for BGP.  

This had its two main reasons.  
*   First is obviously the technical side. 
It's rare for someone to have eBGP running inside their lab.
Plus, I am very interested in BGP since its the protocol that connects the entire internet.  


*   Second are the cons of LACP.
For now, the CCR2004 and CRS326 were connected through two 10GbE OM3 Multimode fiber patchcords with Brocade 10G-SR LC/UPC Duplex SFP transceivers.  


However, they were actually a single logical connection because of the LACP. 
The `bond0` interface used 802.3ad protocol to agregate the traffic between those two physical links to utilize them as a single logical interface.
But LACP has it's disadvantages. 
I actually experienced some problems with LACP. 
More specifically with the reconvergence time.
I don't really know if that's the RouterOS specifics or just it's the general con of bonding interfaces, but it was not 100% seamless when one link failed.  

All of that, plus the fact that BGP is very useful and a crucial part of work in a datacenter, brought me to think about eBGP.  

With BGP I could stop using LACP and just create two idependent links which would create a ECMP connection.


