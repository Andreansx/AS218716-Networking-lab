# 2025-09-12 17:47:20 by RouterOS 7.19.4
# software id = 91XQ-9UAD
#
# model = CCR2004-1G-12S+2XS
# serial number = D4F00DCEEFD0
/interface bridge
add name=bridge0
/interface vlan
add interface=sfp-sfpplus1 name=eBGP-Link-0 vlan-id=100
add interface=sfp-sfpplus2 name=eBGP-Link-1 vlan-id=104
/interface list
add name=ZONE-CCR2004-MGMT
add name=ZONE-WAN
add name=eBGP-LINK-CRS326
add name=ZONE-LOOPBACK
add name=ZONE-TO-CRS326-L2
/interface lte apn
set [ find default=yes ] ip-type=ipv4 use-network-apn=no
/ip pool
add name=pool-bare-metal ranges=10.1.2.2-10.1.2.29
add name=pool-users ranges=10.1.3.50-10.1.3.200
add name=pool-vms-cts ranges=10.1.4.50-10.1.4.200
add name=pool-kubernetes ranges=10.1.5.2-10.1.5.30
/ip dhcp-server
add address-pool=pool-users interface=bridge0 lease-time=5d name=dhcp-users \
    relay=10.1.3.1 server-address=172.16.0.1
add address-pool=pool-vms-cts interface=bridge0 lease-time=5d name=\
    dhcp-vlan40 relay=10.1.4.1 server-address=172.16.0.1
add address-pool=pool-bare-metal interface=bridge0 lease-time=5d name=\
    dhcp-vlan20 relay=10.1.2.1 server-address=172.16.0.1
add address-pool=pool-kubernetes interface=bridge0 lease-time=1w3d name=\
    dhcp-kubernetes relay=10.1.5.1 server-address=172.16.0.1
/port
set 0 name=serial0
/routing ospf instance
add disabled=yes name=backbonev2 router-id=172.16.0.1
/routing ospf area
add disabled=yes instance=backbonev2 name=backbone0v2
/interface bridge port
add bridge=bridge0 interface=eBGP-LINK-CRS326
/ip neighbor discovery-settings
set discover-interface-list=!ZONE-TO-CRS326-L2 mode=rx-only
/interface list member
add interface=sfp-sfpplus12 list=ZONE-WAN
add interface=bridge0 list=ZONE-LOOPBACK
add interface=eBGP-Link-0 list=eBGP-LINK-CRS326
add interface=eBGP-Link-1 list=eBGP-LINK-CRS326
add interface=eBGP-Link-0 list=ZONE-TO-CRS326-L2
add interface=eBGP-Link-1 list=ZONE-TO-CRS326-L2
add interface=bridge0 list=ZONE-TO-CRS326-L2
add interface=ether1 list=ZONE-CCR2004-MGMT
/ip address
add address=10.0.0.150/24 comment=WAN interface=sfp-sfpplus12 network=\
    10.0.0.0
add address=10.1.1.1/30 interface=ether1 network=10.1.1.0
add address=172.16.255.1/30 interface=eBGP-Link-0 network=172.16.255.0
add address=172.16.0.1 interface=bridge0 network=172.16.0.1
add address=172.16.255.5/30 interface=eBGP-Link-1 network=172.16.255.4
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
set servers=1.1.1.1,8.8.8.8
/ip firewall address-list
add address=10.1.1.4/30 list=CRS326-MGMT
add address=10.1.2.0/24 list=SERVERs-NET
add address=10.1.4.0/24 list=VMs/LXCs-NET
add address=10.1.5.0/27 list=Kubernetes-NET
add address=172.16.0.1 list=BGP_ADV_NET
add address=0.0.0.0/0 list=BGP_ADV_NET
/ip firewall filter
add action=accept chain=input connection-state=established,related
add action=accept chain=forward comment=\
    "Allowing already established connections" connection-state=\
    established,related
add action=accept chain=input in-interface-list=ZONE-CCR2004-MGMT
add action=accept chain=input in-interface-list=ZONE-TO-CRS326-L2 protocol=\
    icmp
add action=accept chain=input in-interface-list=ZONE-TO-CRS326-L2 protocol=\
    ospf
add action=accept chain=input in-interface-list=ZONE-LOOPBACK port=67,68 \
    protocol=udp
add action=accept chain=forward in-interface-list=ZONE-CCR2004-MGMT \
    out-interface-list=ZONE-TO-CRS326-L2 protocol=icmp
add action=accept chain=forward in-interface-list=ZONE-CCR2004-MGMT \
    out-interface-list=ZONE-TO-CRS326-L2 port=5201 protocol=tcp
add action=accept chain=forward dst-address=172.16.255.8/30 \
    in-interface-list=ZONE-CCR2004-MGMT out-interface-list=ZONE-TO-CRS326-L2 \
    port=22 protocol=tcp
add action=accept chain=forward dst-address-list=SERVERs-NET \
    in-interface-list=ZONE-CCR2004-MGMT out-interface-list=ZONE-TO-CRS326-L2
add action=accept chain=forward dst-address-list=VMs/LXCs-NET \
    in-interface-list=ZONE-CCR2004-MGMT out-interface-list=ZONE-TO-CRS326-L2
add action=accept chain=forward dst-address-list=Kubernetes-NET \
    in-interface-list=ZONE-CCR2004-MGMT out-interface-list=ZONE-TO-CRS326-L2 \
    port=22 protocol=tcp
add action=accept chain=forward dst-address-list=Kubernetes-NET \
    in-interface-list=ZONE-CCR2004-MGMT out-interface-list=ZONE-TO-CRS326-L2 \
    protocol=icmp
add action=accept chain=forward dst-address-list=Kubernetes-NET \
    in-interface-list=ZONE-CCR2004-MGMT out-interface-list=eBGP-LINK-CRS326
add action=accept chain=forward comment=\
    "Accept traffic between CCR2004 Management and CRS326 Management" \
    dst-address-list=CRS326-MGMT in-interface-list=ZONE-CCR2004-MGMT \
    out-interface-list=ZONE-TO-CRS326-L2 port=22,8291,80 protocol=tcp
add action=accept chain=forward in-interface-list=ZONE-TO-CRS326-L2 \
    out-interface-list=ZONE-WAN
add action=accept chain=forward in-interface-list=ZONE-CCR2004-MGMT \
    out-interface-list=ZONE-WAN
add action=drop chain=input
add action=drop chain=forward comment="Dropping all other forward traffic"
/ip firewall nat
add action=masquerade chain=srcnat out-interface=sfp-sfpplus12
/ip route
add disabled=no dst-address=0.0.0.0/0 gateway=10.0.0.1
add disabled=no dst-address=10.1.1.4/30 gateway=172.16.255.2
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
/ipv6 nd
set [ find default=yes ] advertise-dns=no advertise-mac-address=no
/routing bgp connection
add afi=ip as=65000 disabled=no keepalive-time=20s local.role=ebgp name=\
    eBGP-0 output.network=BGP_ADV_NET remote.address=172.16.255.2 router-id=\
    172.16.0.1 routing-table=main
add as=65000 disabled=no keepalive-time=20s local.role=ebgp name=eBGP-1 \
    output.network=BGP_ADV_NET remote.address=172.16.255.6 router-id=\
    172.16.0.1
/routing ospf interface-template
add area=backbone0v2 disabled=yes networks=172.16.0.1/32 passive
add area=backbone0v2 disabled=yes networks=172.16.255.0/30
add area=backbone0v2 disabled=yes networks=172.16.255.4/30
/system clock
set time-zone-name=Europe/Warsaw
/system identity
set name=edge-leaf-ccr2004
/system resource irq rps
set ether1 disabled=no
