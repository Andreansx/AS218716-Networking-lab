# jun/17/2025 20:24:22 by RouterOS 6.49.18
# software id = 91XQ-9UAD
#
# model = CCR2004-1G-12S+2XS
# serial number = -
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip pool
add name=lan-pool ranges=10.10.0.2-10.10.0.254
/ip dhcp-server
add address-pool=lan-pool disabled=no interface=ether1 name=lan-dhcp
/ip address
add address=192.168.88.1/24 comment=defconf interface=ether1 network=\
    192.168.88.0
add address=10.0.0.150/24 interface=sfp-sfpplus12 network=10.0.0.0
add address=10.10.0.1/24 interface=ether1 network=10.10.0.0
/ip dhcp-server network
add address=10.10.0.0/24 comment="LAN DHCP network" dns-server=\
    1.1.1.1,8.8.8.8 gateway=10.10.0.1
/ip dns
set servers=1.1.1.1,8.8.8.8
/ip dns static
add address=1.1.1.1 name=cloudflare
/ip firewall nat
add action=masquerade chain=srcnat out-interface=sfp-sfpplus12
/ip route
add distance=1 gateway=10.0.0.1
/system clock
set time-zone-name=Europe/Warsaw
/system identity
set name=ccr2004
