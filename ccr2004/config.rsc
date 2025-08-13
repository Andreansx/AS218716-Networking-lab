# 2025-08-13 00:27:38 by RouterOS 7.19.4
# software id = 91XQ-9UAD
#
# model = CCR2004-1G-12S+2XS
# serial number = D4F00DCEEFD0
/interface bridge
add name=ccr2004-mgmt port-cost-mode=short
add name=loopback0
/interface vlan
add interface=sfp-sfpplus1 name=inter-router-link0 vlan-id=100
add interface=sfp-sfpplus1 name=vlan20-bare-metal vlan-id=20
add interface=sfp-sfpplus1 name=vlan30-users vlan-id=30
add interface=sfp-sfpplus1 name=vlan40-vms-cts vlan-id=40
add interface=sfp-sfpplus1 name=vlan111-ccr2004-mgmt vlan-id=111
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
/ip dhcp-server
add address-pool=pool-users interface=vlan30-users lease-time=5d name=\
    dhcp-users
add address-pool=pool-vms-cts interface=inter-router-link0 lease-time=5d \
    name=dhcp-vlan40 relay=10.1.4.1
add address-pool=pool-bare-metal interface=inter-router-link0 lease-time=5d \
    name=dhcp-vlan20 relay=10.1.2.1
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
add interface=vlan30-users list=ZONE-USERS
add interface=sfp-sfpplus12 list=ZONE-WAN
add interface=ccr2004-mgmt list=ZONE-CCR2004-MGMT
add interface=inter-router-link0 list=LINK-TO-CRS326
/ip address
add address=10.0.0.150/24 comment=WAN interface=sfp-sfpplus12 network=\
    10.0.0.0
add address=10.1.3.1/24 interface=vlan30-users network=10.1.3.0
add address=10.1.1.1/30 interface=ccr2004-mgmt network=10.1.1.0
add address=172.16.255.1/30 interface=inter-router-link0 network=172.16.255.0
add address=172.16.0.1 interface=loopback0 network=172.16.0.1
/ip dhcp-server network
add address=10.1.2.0/27 dns-server=1.1.1.1 gateway=10.1.2.1
add address=10.1.3.0/24 dns-server=1.1.1.1 gateway=10.1.3.1
add address=10.1.4.0/24 dns-server=1.1.1.1 gateway=10.1.4.1
/ip dns
set servers=10.100.40.99,1.1.1.1
/ip firewall address-list
add address=10.1.1.4/30 list=CRS326-MGMT
add address=10.1.2.0/24 list=SERVERs-NET
add address=10.1.4.0/24 list=VMs/LXCs-NET
/ip firewall filter
add action=accept chain=input connection-state=established,related disabled=\
    yes
add action=accept chain=forward comment=\
    "Allowing already established connections" connection-state=\
    established,related disabled=yes
add action=accept chain=input disabled=yes in-interface-list=\
    ZONE-CCR2004-MGMT
add action=accept chain=input disabled=yes in-interface-list=LINK-TO-CRS326 \
    protocol=icmp
add action=accept chain=forward disabled=yes dst-address-list=SERVERs-NET \
    in-interface-list=ZONE-CCR2004-MGMT out-interface-list=LINK-TO-CRS326
add action=accept chain=forward disabled=yes dst-address-list=VMs/LXCs-NET \
    in-interface-list=ZONE-CCR2004-MGMT out-interface-list=LINK-TO-CRS326
add action=accept chain=forward disabled=yes in-interface-list=\
    ZONE-CCR2004-MGMT out-interface-list=ZONE-USERS
add action=accept chain=forward comment=\
    "Accept traffic between CCR2004 Management and CRS326 Management" \
    disabled=yes dst-address-list=CRS326-MGMT in-interface-list=\
    ZONE-CCR2004-MGMT out-interface-list=LINK-TO-CRS326 port=22,8291 \
    protocol=tcp
add action=drop chain=forward comment=\
    "Block traffic from users to networks behind CRS326" disabled=yes \
    in-interface-list=ZONE-USERS out-interface-list=LINK-TO-CRS326
add action=accept chain=forward disabled=yes in-interface-list=ZONE-USERS \
    out-interface-list=ZONE-WAN
add action=accept chain=forward disabled=yes in-interface-list=LINK-TO-CRS326 \
    out-interface-list=ZONE-WAN
add action=accept chain=forward disabled=yes in-interface-list=\
    ZONE-CCR2004-MGMT out-interface-list=ZONE-WAN
add action=drop chain=input disabled=yes
add action=drop chain=forward comment="Dropping all other forward traffic" \
    disabled=yes
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
add area=backbone0v2 disabled=no networks=10.1.3.0/24 passive
/system clock
set time-zone-name=Europe/Warsaw
/system identity
set name=core-ccr2004
/system resource irq rps
set ether1 disabled=no
