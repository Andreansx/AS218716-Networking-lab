# 2025-08-19 17:40:53 by RouterOS 7.19.4
# software id = N85J-2N9M
#
# model = CRS326-24S+2Q+
# serial number = HGB09MRF1PQ
/interface bridge
add name=loopback0
add admin-mac=D4:01:C3:75:18:94 auto-mac=no comment=defconf name=main-bridge \
    vlan-filtering=yes
/interface vlan
add interface=main-bridge name=inter-router-link0 vlan-id=100
add interface=main-bridge name=vlan20-bare-metal vlan-id=20
add interface=main-bridge name=vlan30-users vlan-id=30
add interface=main-bridge name=vlan40-vms-cts vlan-id=40
add interface=main-bridge name=vlan50-kubernetes vlan-id=50
add interface=main-bridge name=vlan115-crs326-mgmt vlan-id=115
/interface bonding
add mode=802.3ad name=bond0 slaves=sfp-sfpplus1,sfp-sfpplus24 \
    transmit-hash-policy=layer-2-and-3
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/port
set 0 name=serial0
/routing ospf instance
add disabled=no name=backbonev2 router-id=172.16.0.2
/routing ospf area
add disabled=no instance=backbonev2 name=backbone0v2
/interface bridge port
add bridge=main-bridge interface=ether1 pvid=115 trusted=yes
add bridge=main-bridge interface=qsfpplus1-1
add bridge=main-bridge interface=qsfpplus1-2
add bridge=main-bridge interface=qsfpplus1-3
add bridge=main-bridge interface=qsfpplus1-4
add bridge=main-bridge interface=qsfpplus2-1
add bridge=main-bridge interface=qsfpplus2-2
add bridge=main-bridge interface=qsfpplus2-3
add bridge=main-bridge interface=qsfpplus2-4
add bridge=main-bridge interface=sfp-sfpplus5
add bridge=main-bridge interface=sfp-sfpplus6 pvid=30
add bridge=main-bridge interface=sfp-sfpplus7
add bridge=main-bridge interface=sfp-sfpplus8
add bridge=main-bridge interface=sfp-sfpplus9
add bridge=main-bridge interface=sfp-sfpplus10
add bridge=main-bridge interface=sfp-sfpplus11
add bridge=main-bridge interface=sfp-sfpplus12
add bridge=main-bridge interface=sfp-sfpplus13
add bridge=main-bridge interface=sfp-sfpplus14
add bridge=main-bridge interface=sfp-sfpplus15
add bridge=main-bridge interface=sfp-sfpplus16
add bridge=main-bridge interface=sfp-sfpplus17
add bridge=main-bridge interface=sfp-sfpplus18
add bridge=main-bridge interface=sfp-sfpplus19
add bridge=main-bridge interface=sfp-sfpplus20
add bridge=main-bridge interface=sfp-sfpplus21
add bridge=main-bridge interface=sfp-sfpplus22
add bridge=main-bridge interface=sfp-sfpplus23
add bridge=main-bridge edge=yes interface=sfp-sfpplus2
add bridge=main-bridge interface=sfp-sfpplus4
add bridge=main-bridge interface=sfp-sfpplus3
add bridge=main-bridge interface=bond0
/interface bridge vlan
add bridge=main-bridge tagged=main-bridge,sfp-sfpplus2 vlan-ids=20
add bridge=main-bridge tagged=main-bridge,sfp-sfpplus2 vlan-ids=30
add bridge=main-bridge tagged=main-bridge,sfp-sfpplus2 vlan-ids=40
add bridge=main-bridge tagged=main-bridge,bond0 vlan-ids=100
add bridge=main-bridge tagged=main-bridge untagged=ether1 vlan-ids=115
add bridge=main-bridge tagged=main-bridge,sfp-sfpplus2 vlan-ids=50
/interface ethernet switch
set 0 l3-hw-offloading=yes
/ip address
add address=10.1.2.1/27 interface=vlan20-bare-metal network=10.1.2.0
add address=10.1.4.1/24 interface=vlan40-vms-cts network=10.1.4.0
add address=10.1.1.5/30 interface=vlan115-crs326-mgmt network=10.1.1.4
add address=172.16.255.2/30 interface=inter-router-link0 network=172.16.255.0
add address=172.16.0.2 interface=loopback0 network=172.16.0.2
add address=10.1.5.1/27 interface=vlan50-kubernetes network=10.1.5.0
add address=10.1.3.1/24 interface=vlan30-users network=10.1.3.0
/ip dhcp-relay
add dhcp-server=172.16.255.1 disabled=no interface=vlan20-bare-metal name=\
    vlan20-dhcp-relay
add dhcp-server=172.16.255.1 disabled=no interface=vlan40-vms-cts name=\
    vlan40-dhcp-relay
add dhcp-server=172.16.255.1 disabled=no interface=vlan50-kubernetes name=\
    kubernetes-dhcp-relay
add dhcp-server=172.16.255.1 disabled=no interface=vlan30-users name=\
    vlan30-dhcp-relay
/ip dns
set servers=1.1.1.1
/ip firewall address-list
add address=10.1.1.4/30 list=CRS326-MGMT
add address=10.1.4.0/24 list=VMs/LXCs
add address=10.1.2.0/27 list=SERVERs
/ip firewall filter
add action=drop chain=input dst-address-list=CRS326-MGMT src-address-list=\
    SERVERs,VMs/LXCs
/ip route
add gateway=172.16.255.1
/ip service
set ftp disabled=yes
set www disabled=yes
set api disabled=yes
/routing ospf interface-template
add area=backbone0v2 disabled=no networks=172.16.0.2/32 passive
add area=backbone0v2 disabled=no networks=172.16.255.0/30
add area=backbone0v2 disabled=no networks=10.1.2.0/27 passive
add area=backbone0v2 disabled=no networks=10.1.4.0/24 passive
add area=backbone0v2 disabled=no networks=10.1.5.0/27 passive
add area=backbone0v2 disabled=no networks=10.1.3.0/24 passive
/system clock
set time-zone-name=Europe/Warsaw
/system identity
set name=core-crs326
/system routerboard settings
set enter-setup-on=delete-key
/system swos
set address-acquisition-mode=static identity=SW_CORE_02 static-ip-address=\
    10.10.20.13
