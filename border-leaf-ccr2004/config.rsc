# 2026-02-05 18:03:02 by RouterOS 7.19.4
# software id = 91XQ-9UAD
#
# model = CCR2004-1G-12S+2XS
# serial number = D4F00DCEEFD0
/interface bridge
add name=bridge0
/interface vlan
add interface=sfp-sfpplus1 name=eBGP_LINK_AS65001_0 vlan-id=100
add interface=sfp-sfpplus2 name=eBGP_LINK_AS65001_1 vlan-id=102
add interface=sfp-sfpplus3 name=eBGP_LINK_AS65001_2 vlan-id=104
/interface list
add name=ZONE-CCR2004-MGMT
add name=ZONE-WAN
add name=ZONE_BGP_AS65001
add name=ZONE-LOOPBACK
add name=ZONE-TO-CRS326-L2
/interface lte apn
set [ find default=yes ] ip-type=ipv4 use-network-apn=no
/ip pool
add name=pool-bare-metal ranges=10.1.2.2-10.1.2.29
add name=pool-users ranges=10.1.3.50-10.1.3.200
add name=pool-vms-cts ranges=10.1.4.50-10.1.4.200
add name=pool-kubernetes ranges=10.1.5.2-10.1.5.30
add name=mgmt-pool ranges=10.1.99.50-10.1.99.200
/ip dhcp-server
add address-pool=pool-users interface=bridge0 lease-time=5d name=dhcp-users \
    relay=10.1.3.1 server-address=172.16.0.1
add address-pool=pool-vms-cts always-broadcast=yes conflict-detection=no \
    interface=bridge0 lease-time=5d name=dhcp-vlan40 relay=10.1.4.1 \
    server-address=172.16.0.1
add address-pool=pool-bare-metal interface=bridge0 lease-time=5d name=\
    dhcp-vlan20 relay=10.1.2.1 server-address=172.16.0.1
add address-pool=pool-kubernetes interface=bridge0 lease-time=1w3d name=\
    dhcp-kubernetes relay=10.1.5.1 server-address=172.16.0.1
add address-pool=mgmt-pool interface=ether1 lease-time=4w2d name=dhcp-mgmt
/ip vrf
add interfaces=ether1 name=vrf-mgmt
/port
set 0 name=serial0
/routing ospf instance
add disabled=yes name=backbonev2 router-id=172.16.0.1
/routing ospf area
add disabled=yes instance=backbonev2 name=backbone0v2
/interface bridge port
add bridge=bridge0 interface=ZONE_BGP_AS65001
/ip neighbor discovery-settings
set discover-interface-list=!ZONE-TO-CRS326-L2 mode=rx-only
/interface list member
add interface=sfp-sfpplus12 list=ZONE-WAN
add interface=bridge0 list=ZONE-LOOPBACK
add interface=eBGP_LINK_AS65001_0 list=ZONE_BGP_AS65001
add interface=eBGP_LINK_AS65001_1 list=ZONE_BGP_AS65001
add interface=eBGP_LINK_AS65001_0 list=ZONE-TO-CRS326-L2
add interface=eBGP_LINK_AS65001_1 list=ZONE-TO-CRS326-L2
add interface=bridge0 list=ZONE-TO-CRS326-L2
add interface=ether1 list=ZONE-CCR2004-MGMT
add interface=eBGP_LINK_AS65001_2 list=ZONE_BGP_AS65001
add interface=eBGP_LINK_AS65001_2 list=ZONE-TO-CRS326-L2
/ip address
add address=10.1.99.1/24 interface=ether1 network=10.1.99.0
add address=172.16.255.0/31 interface=eBGP_LINK_AS65001_0 network=\
    172.16.255.0
add address=172.16.0.1 interface=bridge0 network=172.16.0.1
add address=172.16.255.2/31 interface=eBGP_LINK_AS65001_1 network=\
    172.16.255.2
add address=172.16.255.4/31 interface=eBGP_LINK_AS65001_2 network=\
    172.16.255.4
add address=10.0.0.2/24 interface=sfp-sfpplus12 network=10.0.0.0
/ip dhcp-server lease
add address=10.1.5.30 mac-address=BC:24:11:80:55:00
add address=10.1.5.29 mac-address=BC:24:11:80:55:01
add address=10.1.5.28 mac-address=BC:24:11:80:55:02
/ip dhcp-server network
add address=10.1.2.0/27 dns-server=1.1.1.1 gateway=10.1.2.1
add address=10.1.3.0/24 dns-server=1.1.1.1 gateway=10.1.3.1
add address=10.1.4.0/24 dns-server=1.1.1.1 gateway=10.1.4.1
add address=10.1.5.0/27 dns-server=1.1.1.1,8.8.8.8 gateway=10.1.5.1
add address=10.1.99.0/24 dns-server=1.1.1.1,8.8.8.8 gateway=10.1.99.1
/ip dns
set servers=1.1.1.1,8.8.8.8
/ip firewall address-list
add address=10.1.4.0/24 list=VMs/LXCs-NET
add address=10.1.5.0/27 list=Kubernetes-NET
add address=172.16.0.1 list=BGP_ADV_NET
add address=0.0.0.0/0 list=BGP_ADV_NET
add address=10.0.0.0/24 list=ISP_ROUTER_NET
add address=10.1.99.0/24 list=MGMT
/ip firewall filter
add action=accept chain=input connection-state=established,related
add action=accept chain=forward connection-state=established,related
add action=accept chain=input protocol=icmp
add action=accept chain=forward protocol=icmp
add action=accept chain=input dst-port=179 protocol=tcp
add action=accept chain=input dst-port=22 in-interface=vrf-mgmt protocol=tcp
add action=accept chain=forward out-interface=sfp-sfpplus12
add action=accept chain=forward dst-address=10.1.4.51 dst-port=8096 \
    in-interface=sfp-sfpplus12 protocol=tcp
add action=accept chain=forward dst-address=10.1.4.51 dst-port=8096 protocol=\
    tcp src-address-list=MGMT
add action=drop chain=input comment=deny-by-default-input
add action=drop chain=forward comment=deny-by-default-forward
/ip firewall mangle
add action=mark-connection chain=prerouting in-interface=ether1 \
    new-connection-mark=mgmt-to-wan
add action=mark-routing chain=prerouting connection-mark=mgmt-to-wan \
    in-interface=sfp-sfpplus12 new-routing-mark=vrf-mgmt passthrough=no
/ip firewall nat
add action=dst-nat chain=dstnat dst-address=10.0.0.2 dst-port=42321 protocol=\
    tcp to-addresses=10.1.4.51 to-ports=8096
add action=dst-nat chain=dstnat dst-address=10.0.0.2 dst-port=42322 protocol=\
    tcp to-addresses=10.1.4.51 to-ports=22
add action=dst-nat chain=dstnat disabled=yes dst-address=10.0.0.2 dst-port=\
    42323 protocol=tcp to-addresses=10.1.1.2 to-ports=8000
add action=masquerade chain=srcnat out-interface=sfp-sfpplus12
/ip route
add disabled=no dst-address=0.0.0.0/0 gateway=10.0.0.1
add disabled=no dst-address=10.1.1.4/30 gateway=172.16.255.1
add disabled=no dst-address=10.1.3.0/24 gateway=172.16.255.1
add disabled=no dst-address=0.0.0.0/0 gateway=10.0.0.1@main routing-table=\
    vrf-mgmt
/ip service
set ftp disabled=yes
set ssh address=10.1.99.0/24 vrf=vrf-mgmt
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
/ipv6 nd
set [ find default=yes ] advertise-dns=no advertise-mac-address=no
/routing bgp connection
add as=4201000001 disabled=no keepalive-time=20s local.role=ebgp name=\
    eBGP_CON_AS65001_0 output.default-originate=if-installed .network=\
    BGP_ADV_NET remote.address=172.16.255.1 .as=4201000002 router-id=\
    172.16.0.1 routing-table=main
add as=4201000001 disabled=no keepalive-time=20s local.role=ebgp name=\
    eBGP_CON_AS65001_1 output.default-originate=if-installed .network=\
    BGP_ADV_NET remote.address=172.16.255.3 .as=4201000002 router-id=\
    172.16.0.1 routing-table=main
add as=4201000001 disabled=no keepalive-time=20s local.role=ebgp name=\
    eBGP_CON_AS65001_2 output.default-originate=if-installed .network=\
    BGP_ADV_NET remote.address=172.16.255.5 .as=4201000002 router-id=\
    172.16.0.1 routing-table=main
/routing ospf interface-template
add area=backbone0v2 disabled=yes networks=172.16.0.1/32 passive
add area=backbone0v2 disabled=yes networks=172.16.255.0/30
add area=backbone0v2 disabled=yes networks=172.16.255.4/30
/system clock
set time-zone-name=Europe/Warsaw
/system identity
set name=border-leaf-ccr2004
/system logging
add topics=dhcp,debug
add topics=natpmp,firewall
add topics=debug,firewall
/system resource irq rps
set ether1 disabled=no
