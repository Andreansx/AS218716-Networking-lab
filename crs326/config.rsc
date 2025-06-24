# 2025-06-24 18:07:01 by RouterOS 7.16.2
# software id = N85J-2N9M
#
# model = CRS326-24S+2Q+
# serial number = 
/interface bridge
add admin-mac=D4:01:C3:75:18:94 auto-mac=no comment=defconf name=bridgeLocal vlan-filtering=yes
/interface vlan
add interface=bridgeLocal name=vlan10-mgmt vlan-id=10
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/port
set 0 name=serial0
/interface bridge port
add bridge=bridgeLocal comment=defconf interface=ether1 pvid=10
add bridge=bridgeLocal comment=defconf interface=qsfpplus1-1
add bridge=bridgeLocal comment=defconf interface=qsfpplus1-2
add bridge=bridgeLocal comment=defconf interface=qsfpplus1-3
add bridge=bridgeLocal comment=defconf interface=qsfpplus1-4
add bridge=bridgeLocal comment=defconf interface=qsfpplus2-1
add bridge=bridgeLocal comment=defconf interface=qsfpplus2-2
add bridge=bridgeLocal comment=defconf interface=qsfpplus2-3
add bridge=bridgeLocal comment=defconf interface=qsfpplus2-4
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus1
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus2 pvid=20
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus3 pvid=30
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus4
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus5
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus6
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus7
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus8
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus9
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus10
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus11
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus12
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus13
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus14
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus15
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus16
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus17
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus18
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus19
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus20
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus21
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus22
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus23
add bridge=bridgeLocal comment=defconf interface=sfp-sfpplus24
/interface bridge vlan
add bridge=bridgeLocal tagged=sfp-sfpplus1 untagged=sfp-sfpplus2 vlan-ids=20
add bridge=bridgeLocal tagged=bridgeLocal,sfp-sfpplus1 untagged=ether1 vlan-ids=10
add bridge=bridgeLocal tagged=sfp-sfpplus1 untagged=sfp-sfpplus3 vlan-ids=30
/ip address
add address=10.10.10.2/24 interface=vlan10-mgmt network=10.10.10.0
/ip dhcp-client
add comment=defconf interface=bridgeLocal
/ip dns
set servers=1.1.1.1,8.8.8.8
/ip route
add gateway=10.10.10.1
/system clock
set time-zone-name=Europe/Warsaw
/system note
set show-at-login=no
/system routerboard settings
set enter-setup-on=delete-key
/system swos
set address-acquisition-mode=static identity=SW_CORE_02 static-ip-address=10.10.20.13
