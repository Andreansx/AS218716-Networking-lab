# 2025-08-05 01:54:27 by RouterOS 7.19.4
# software id = N85J-2N9M
#
# model = CRS326-24S+2Q+
# serial number = HGB09MRF1PQ
/interface bridge
add admin-mac=D4:01:C3:75:18:94 auto-mac=no comment=defconf name=main-bridge \
    vlan-filtering=yes
/interface vlan
add interface=main-bridge name=inter-router-link0 vlan-id=100
add interface=main-bridge name=vlan20-bare-metal vlan-id=20
add interface=main-bridge name=vlan40-vms-cts vlan-id=40
add interface=main-bridge name=vlan99-ospf vlan-id=99
add interface=main-bridge name=vlan115-crs326-mgmt vlan-id=115
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/port
set 0 name=serial0
/interface bridge port
add bridge=main-bridge interface=ether1 pvid=10 trusted=yes
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
add bridge=main-bridge interface=sfp-sfpplus2 pvid=20
add bridge=main-bridge interface=sfp-sfpplus4
add bridge=main-bridge interface=sfp-sfpplus3
add bridge=main-bridge interface=sfp-sfpplus1
/interface bridge vlan
add bridge=main-bridge tagged=sfp-sfpplus1 untagged=sfp-sfpplus2 vlan-ids=20
add bridge=main-bridge tagged=sfp-sfpplus1,sfp-sfpplus2 vlan-ids=30
add bridge=main-bridge tagged=sfp-sfpplus1,sfp-sfpplus2 vlan-ids=40
add bridge=main-bridge tagged=sfp-sfpplus1 untagged=ether1 vlan-ids=100
/interface ethernet switch
set 0 l3-hw-offloading=yes
/ip address
add address=10.1.2.1/27 interface=vlan20-bare-metal network=10.1.2.0
add address=10.1.4.1/24 interface=vlan40-vms-cts network=10.1.4.0
add address=10.1.1.5/30 interface=vlan115-crs326-mgmt network=10.1.1.4
add address=10.2.1.2/30 interface=inter-router-link0 network=10.2.1.0
/ip dhcp-relay
add dhcp-server=10.2.1.1 disabled=no interface=vlan20-bare-metal \
    local-address=10.1.1.1 name=vlan20-dhcp-relay
add dhcp-server=10.2.1.1 disabled=no interface=vlan40-vms-cts local-address=\
    10.1.4.1 name=vlan40-dhcp-relay
/ip dns
set servers=1.1.1.1
/ip route
add gateway=10.2.1.1
add dst-address=10.1.3.0/24 gateway=10.2.1.1
/ip service
set ftp disabled=yes
set www disabled=yes
set api disabled=yes
/system clock
set time-zone-name=Europe/Warsaw
/system identity
set name=core-crs326
/system routerboard settings
set enter-setup-on=delete-key
/system swos
set address-acquisition-mode=static identity=SW_CORE_02 static-ip-address=\
    10.10.20.13
