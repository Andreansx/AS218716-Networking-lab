# 2025-07-30 01:52:13 by RouterOS 7.19.3
# software id = N85J-2N9M
#
# model = CRS326-24S+2Q+
# serial number = HGB09MRF1PQ
/interface bridge
add admin-mac=D4:01:C3:75:18:94 auto-mac=no comment=defconf name=main-bridge \
    vlan-filtering=yes
/interface vlan
add interface=main-bridge name=vlan10-mgmt vlan-id=10
add interface=main-bridge name=vlan99-ospf vlan-id=99
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/port
set 0 name=serial0
/interface bridge port
add bridge=main-bridge interface=ether1 pvid=10
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
add bridge=main-bridge interface=sfp-sfpplus24
add bridge=main-bridge interface=sfp-sfpplus1
add bridge=main-bridge interface=sfp-sfpplus2 pvid=20
add bridge=main-bridge interface=sfp-sfpplus4
add bridge=main-bridge interface=sfp-sfpplus3
/interface bridge vlan
add bridge=main-bridge tagged=sfp-sfpplus1 untagged=ether1 vlan-ids=10
add bridge=main-bridge tagged=sfp-sfpplus1,sfp-sfpplus2 vlan-ids=30
add bridge=main-bridge tagged=sfp-sfpplus1,sfp-sfpplus2 vlan-ids=40
add bridge=main-bridge tagged=sfp-sfpplus1 untagged=sfp-sfpplus2 vlan-ids=20
add bridge=main-bridge tagged=sfp-sfpplus1 vlan-ids=99
/ip address
add address=10.100.10.2/28 interface=vlan10-mgmt network=10.100.10.0
add address=10.100.255.2/30 interface=vlan99-ospf network=10.100.255.0
/ip dns
set servers=10.100.40.99
/ip route
add gateway=10.100.10.1
/ip service
set ftp disabled=yes
set ssh address=10.100.10.0/28
set www disabled=yes
set winbox address=10.100.10.0/28
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
