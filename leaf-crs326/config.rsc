# 2026-02-07 12:45:13 by RouterOS 7.19.4
# software id = N85J-2N9M
#
# model = CRS326-24S+2Q+
# serial number = HGB09MRF1PQ
/interface bridge
add admin-mac=D4:01:C3:75:18:94 auto-mac=no comment=defconf mtu=9216 name=\
    main-bridge vlan-filtering=yes
/interface ethernet
set [ find default-name=qsfpplus1-1 ] l2mtu=9216 mtu=9216
set [ find default-name=qsfpplus1-2 ] l2mtu=9216 mtu=9216
set [ find default-name=qsfpplus1-3 ] l2mtu=9216 mtu=9216
set [ find default-name=qsfpplus1-4 ] l2mtu=9216 mtu=9216
set [ find default-name=qsfpplus2-1 ] l2mtu=9216 mtu=9216
set [ find default-name=qsfpplus2-2 ] l2mtu=9216 mtu=9216
set [ find default-name=qsfpplus2-3 ] l2mtu=9216 mtu=9216
set [ find default-name=qsfpplus2-4 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus1 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus2 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus3 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus4 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus5 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus6 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus7 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus8 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus9 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus10 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus11 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus12 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus13 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus14 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus15 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus16 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus17 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus18 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus19 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus20 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus21 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus22 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus23 ] l2mtu=9216 mtu=9216
set [ find default-name=sfp-sfpplus24 ] l2mtu=9216 mtu=9216
/interface vlan
add disabled=yes interface=main-bridge name=eBGP_LINK_AS65000_0 vlan-id=100
add disabled=yes interface=main-bridge name=eBGP_LINK_AS65000_1 vlan-id=102
add disabled=yes interface=main-bridge name=eBGP_LINK_AS65000_2 vlan-id=104
add disabled=yes interface=main-bridge name=eBGP_LINK_AS65002_0 vlan-id=106
add disabled=yes interface=main-bridge name=vlan20-bare-metal vlan-id=20
add disabled=yes interface=main-bridge name=vlan40-vms-cts vlan-id=40
add disabled=yes interface=main-bridge name=vlan50-kubernetes vlan-id=50
add disabled=yes interface=main-bridge name=vlan90-mgmt vlan-id=90
/interface list
add name=ZONE_TO_AS65000
add name=LINK_USERS_NET
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip vrf
add interfaces=ether1 name=vrf-mgmt
/port
set 0 name=serial0
/routing ospf instance
add disabled=yes name=backbonev2 router-id=172.16.0.2
/routing ospf area
add disabled=yes instance=backbonev2 name=backbone0v2
/interface bridge port
add bridge=main-bridge interface=qsfpplus1-1
add bridge=main-bridge interface=qsfpplus1-2
add bridge=main-bridge interface=qsfpplus1-3
add bridge=main-bridge interface=qsfpplus1-4
add bridge=main-bridge interface=qsfpplus2-1
add bridge=main-bridge interface=qsfpplus2-2
add bridge=main-bridge interface=qsfpplus2-3
add bridge=main-bridge interface=qsfpplus2-4
add bridge=main-bridge interface=sfp-sfpplus5
add bridge=main-bridge interface=sfp-sfpplus6
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
add bridge=main-bridge interface=sfp-sfpplus1
add bridge=main-bridge interface=sfp-sfpplus24
/ip neighbor discovery-settings
set mode=rx-only
/interface bridge vlan
add bridge=main-bridge tagged=main-bridge,LINK_USERS_NET vlan-ids=20
add bridge=main-bridge tagged=main-bridge,LINK_USERS_NET vlan-ids=40
add bridge=main-bridge tagged=main-bridge,sfp-sfpplus1 vlan-ids=100
add bridge=main-bridge tagged=main-bridge,LINK_USERS_NET vlan-ids=50
add bridge=main-bridge tagged=main-bridge,sfp-sfpplus3 vlan-ids=102
add bridge=main-bridge tagged=main-bridge,LINK_USERS_NET vlan-ids=106
/interface list member
add interface=eBGP_LINK_AS65000_0 list=ZONE_TO_AS65000
add interface=eBGP_LINK_AS65000_1 list=ZONE_TO_AS65000
add interface=sfp-sfpplus5 list=LINK_USERS_NET
add interface=eBGP_LINK_AS65000_2 list=ZONE_TO_AS65000
/ip address
add address=172.16.0.2 interface=lo network=172.16.0.2
add address=10.1.99.5/24 interface=ether1 network=10.1.99.0
add address=172.16.255.7/31 interface=sfp-sfpplus2 network=172.16.255.6
/ip dhcp-relay
# Interface not running
add dhcp-server=172.16.0.1 disabled=no interface=vlan20-bare-metal \
    local-address-as-src-ip=yes name=vlan20-dhcp-relay
# Interface not running
add dhcp-server=172.16.0.1 disabled=no interface=vlan50-kubernetes \
    local-address-as-src-ip=yes name=kubernetes-dhcp-relay
# Interface not running
add dhcp-server=172.16.0.1 disabled=no interface=vlan40-vms-cts \
    local-address-as-src-ip=yes name=vlan40-dhcp-relay
/ip dhcp-server network
add address=10.1.4.0/24
/ip dns
set servers=1.1.1.1
/ip firewall address-list
add address=172.16.0.2 list=BGP_ADV_NET
add address=10.1.99.0/24 list=MGMT
/ip firewall filter
add action=drop chain=input disabled=yes dst-port=22 protocol=tcp \
    src-address-list=!MGMT
/ip route
add disabled=no dst-address=0.0.0.0/0 gateway=10.1.99.1@vrf-mgmt \
    routing-table=vrf-mgmt
/ip service
set ftp disabled=yes
set ssh address=10.1.99.0/24 vrf=vrf-mgmt
set www address=10.1.99.0/24 disabled=yes vrf=vrf-mgmt
set api disabled=yes
/ipv6 nd
set [ find default=yes ] advertise-dns=no advertise-mac-address=no
/routing bgp connection
add as=4200000002 local.role=ebgp name=eBGP_CON_AS4200000000 output.network=\
    BGP_ADV_NET remote.address=172.16.255.6 .as=4200000000 router-id=\
    172.16.0.2 routing-table=main
/routing ospf interface-template
add area=backbone0v2 disabled=yes networks=172.16.0.2/32 passive
add area=backbone0v2 disabled=yes networks=172.16.255.0/30
add area=backbone0v2 disabled=yes networks=10.1.2.0/27 passive
add area=backbone0v2 disabled=yes networks=10.1.4.0/24 passive
add area=backbone0v2 disabled=yes networks=10.1.5.0/27 passive
add area=backbone0v2 disabled=yes networks=10.1.3.0/24 passive
add area=backbone0v2 disabled=yes networks=172.16.255.4/30
/system identity
set name=leaf-crs326
/system logging
add topics=dhcp,debug
/system routerboard settings
set enter-setup-on=delete-key
/system swos
set address-acquisition-mode=static identity=SW_CORE_02 static-ip-address=\
    10.10.20.13
/tool sniffer
set filter-ip-protocol=udp filter-port=bootps
