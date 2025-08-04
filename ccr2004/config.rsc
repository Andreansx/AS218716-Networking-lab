# 2025-08-04 23:34:49 by RouterOS 7.19.4
# software id = 91XQ-9UAD
#
# model = CCR2004-1G-12S+2XS
# serial number = D4F00DCEEFD0
/interface bridge
add name=ccr2004-mgmt port-cost-mode=short
/interface vlan
add interface=sfp-sfpplus1 name=inter-router-link0 vlan-id=100
add interface=sfp-sfpplus1 name=vlan10-management vlan-id=10
add interface=sfp-sfpplus1 name=vlan20-bare-metal vlan-id=20
add interface=sfp-sfpplus1 name=vlan30-users vlan-id=30
add interface=sfp-sfpplus1 name=vlan40-vms-cts vlan-id=40
add interface=sfp-sfpplus1 name=vlan111-ccr2004-mgmt vlan-id=111
/interface lte apn
set [ find default=yes ] ip-type=ipv4 use-network-apn=no
/ip pool
add name=pool-management ranges=10.100.10.3-10.100.10.14
add name=pool-bare-metal ranges=10.1.2.2-10.1.2.30
add name=pool-users ranges=10.1.3.50-10.1.3.200
add name=pool-vms-cts ranges=10.1.4.50-10.1.4.200
/ip dhcp-server
add address-pool=pool-management interface=ccr2004-mgmt lease-time=10m name=\
    dhcp-mgmt
# No IP address on interface
add address-pool=pool-bare-metal interface=vlan20-bare-metal lease-time=10m \
    name=dhcp-servers
add address-pool=pool-users interface=vlan30-users lease-time=10m name=\
    dhcp-users
# No IP address on interface
add address-pool=pool-vms-cts interface=vlan40-vms-cts lease-time=10m name=\
    dhcp-vms-cts
/port
set 0 name=serial0
/interface bridge port
add bridge=ccr2004-mgmt comment="access for laptop" ingress-filtering=no \
    interface=ether1 internal-path-cost=10 path-cost=10
add bridge=ccr2004-mgmt comment="connects vlan10 to this bridge" \
    ingress-filtering=no interface=vlan10-management internal-path-cost=10 \
    path-cost=10
add bridge=ccr2004-mgmt interface=vlan111-ccr2004-mgmt
/ip address
add address=10.0.0.150/24 comment=WAN interface=sfp-sfpplus12 network=\
    10.0.0.0
add address=10.100.10.1/28 interface=ccr2004-mgmt network=10.100.10.0
add address=10.1.3.1/24 interface=vlan30-users network=10.1.3.0
add address=10.1.1.1/30 interface=ccr2004-mgmt network=10.1.1.0
add address=10.2.1.1/30 interface=inter-router-link0 network=10.2.1.0
/ip dhcp-server network
add address=10.1.1.0/27 dns-server=1.1.1.1 gateway=10.1.1.1
add address=10.1.3.0/24 dns-server=1.1.1.1 gateway=10.1.3.1
add address=10.1.4.0/24 dns-server=1.1.1.1 gateway=10.1.4.1
add address=10.100.10.0/28 dns-server=1.1.1.1 gateway=10.100.10.1
/ip dns
set servers=10.100.40.99,1.1.1.1
/ip firewall address-list
add address=10.100.10.0/28 list=management
add address=10.1.2.0/27 list=bare-metal
add address=10.1.3.0/24 list=users
add address=10.1.4.0/24 list=vms-cts
/ip firewall filter
add action=drop chain=input in-interface=sfp-sfpplus12 port=22 protocol=tcp
add action=accept chain=input comment="Allow SSH access from management VLAN" \
    src-address-list=management
add action=accept chain=input comment="Allow established connection access" \
    connection-state=established,related
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
    "Allow bare-metal VLAN to access VMs/CTs VLAN" dst-address-list=vms-cts \
    src-address-list=bare-metal
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
add dst-address=10.100.10.16/28 gateway=10.100.10.2
add disabled=no dst-address=0.0.0.0/0 gateway=10.0.0.1
add dst-address=10.100.40.0/24 gateway=10.100.10.2
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
/system clock
set time-zone-name=Europe/Warsaw
/system identity
set name=core-ccr2004
/system resource irq rps
set ether1 disabled=no
