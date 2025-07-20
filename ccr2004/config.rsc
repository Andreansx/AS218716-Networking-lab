# jul/20/2025 18:33:09 by RouterOS 6.49.18
# software id = 91XQ-9UAD
#
# model = CCR2004-1G-12S+2XS
# serial number = D4F00DCEEFD0
/interface bridge
add name=br-mgmt
/interface vlan
add interface=sfp-sfpplus11 name=vlan10-management vlan-id=10
add interface=sfp-sfpplus11 name=vlan20-bare-metal vlan-id=20
add interface=sfp-sfpplus11 name=vlan30-users vlan-id=30
add interface=sfp-sfpplus11 name=vlan40-vms-cts vlan-id=40
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip pool
add name=pool-management ranges=10.10.10.100-10.10.10.200
add name=pool-bare-metal ranges=10.10.20.100-10.10.20.200
add name=pool-users ranges=10.10.30.100-10.10.30.200
add name=pool-vms-cts ranges=10.10.40.100-10.10.40.200
/ip dhcp-server
add address-pool=pool-management disabled=no interface=br-mgmt name=dhcp-mgmt
add address-pool=pool-bare-metal disabled=no interface=vlan20-bare-metal \
    name=dhcp-servers
add address-pool=pool-users disabled=no interface=vlan30-users name=\
    dhcp-users
add address-pool=pool-vms-cts disabled=no interface=vlan40-vms-cts name=\
    dhcp-vms-cts
/interface bridge port
add bridge=br-mgmt comment="access for laptop" interface=ether1
add bridge=br-mgmt comment="connects vlan10 to this bridge" interface=\
    vlan10-management
/ip address
add address=10.0.0.150/24 comment=WAN interface=sfp-sfpplus12 network=\
    10.0.0.0
add address=10.10.10.1/24 comment="gateway for mgmt" interface=br-mgmt \
    network=10.10.10.0
add address=10.10.20.1/24 comment="gateway for servers" interface=\
    vlan20-bare-metal network=10.10.20.0
add address=10.10.30.1/24 comment="gateway for users" interface=vlan30-users \
    network=10.10.30.0
add address=10.10.40.1/24 comment="gateway for vms, cts" interface=\
    vlan40-vms-cts network=10.10.40.0
/ip dhcp-server network
add address=10.10.10.0/24 dns-server=1.1.1.1,8.8.8.8 gateway=10.10.10.1
add address=10.10.20.0/24 dns-server=1.1.1.1,8.8.8.8 gateway=10.10.20.1
add address=10.10.30.0/24 dns-server=1.1.1.1,8.8.8.8 gateway=10.10.30.1
add address=10.10.40.0/24 dns-server=1.1.1.1,8.8.8.8 gateway=10.10.40.1
/ip dns
set servers=1.1.1.1,8.8.8.8
/ip firewall address-list
add address=10.10.10.0/24 list=management
add address=10.10.20.0/24 list=bare-metal
add address=10.10.30.0/24 list=users
add address=10.10.40.0/24 list=vms-cts
/ip firewall filter
add action=drop chain=input in-interface=sfp-sfpplus12 port=22 protocol=tcp
add action=accept chain=input connection-state=established,related
add action=accept chain=input comment="Allow SSH access from management VLAN" \
    src-address-list=management
add action=accept chain=input protocol=icmp
add action=drop chain=input in-interface=sfp-sfpplus12
add action=accept chain=forward comment=\
    "Allow established, related connections" connection-state=\
    established,related
add action=accept chain=forward comment=\
    "Allow management VLAN to access everything" src-address-list=management
add action=accept chain=forward comment=\
    "Allow users VLAN to access bare-metal VLAN" dst-address-list=bare-metal \
    src-address-list=users
add action=accept chain=forward comment=\
    "Allow VMs/CTs VLAN to access bare-metal VLAN" dst-address-list=\
    bare-metal src-address-list=vms-cts
add action=drop chain=forward comment=\
    "Drop all traffic from VMs/CTs VLAN trying to access Management VLAN" \
    dst-address-list=management src-address-list=vms-cts
add action=drop chain=forward comment=\
    "Drop any traffic trying to enter Management VLAN by default" \
    dst-address-list=management
add action=drop chain=forward comment=\
    "Drop bare-metal VLAN initiating to Users VLAN" dst-address-list=users \
    src-address-list=bare-metal
add action=accept chain=forward comment="Allow all VLANs to access internet" \
    out-interface=sfp-sfpplus12
add action=drop chain=forward comment="Drop any other unrecognized traffic"
add action=drop chain=input comment="Drop any other input traffic"
/ip firewall nat
add action=masquerade chain=srcnat out-interface=sfp-sfpplus12
/ip route
add distance=1 gateway=10.0.0.1
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set ssh address=10.10.10.0/24
set api disabled=yes
set winbox address=10.10.10.0/24
/system clock
set time-zone-name=Europe/Warsaw
/system identity
set name=ccr
/system package update
set channel=upgrade
/system script
add comment=ping dont-require-permissions=no name=qping owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    "ping 1.1.1.1"
