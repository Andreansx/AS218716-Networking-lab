# Troubleshooting OSPF, L2 loop and PVE network configuration

In this case study I would like to talk about a massive issue that happened to me in my lab. 
It took down the entire OSPF Instance and completly disabled access from two ends of my network to each other.  

First I would like to state every IP address for clarity.   

*   **CCR2004**
    *   `ccr2004-mgmt`, `SVI 111` - `10.1.1.1/30` on `ether1`
    *   `inter-router-link0`, `SVI 100` - `172.16.255.1/30` 
<details>
<summary> config.rsc </summary>
    
```rsc
/interface bridge
add name=ccr2004-mgmt port-cost-mode=short
add name=loopback0
/interface vlan
add interface=sfp-sfpplus1 name=inter-router-link0 vlan-id=100
add interface=sfp-sfpplus1 name=vlan20-bare-metal vlan-id=20
add interface=sfp-sfpplus1 name=vlan30-users vlan-id=30
add interface=sfp-sfpplus1 name=vlan40-vms-cts vlan-id=40
add interface=sfp-sfpplus1 name=vlan111-ccr2004-mgmt vlan-id=111
/interface list
add name=ZONE-USERS
add name=ZONE-CCR2004-MGMT
add name=ZONE-WAN
add name=LINK-TO-CRS326
/interface lte apn
set [ find default=yes ] ip-type=ipv4 use-network-apn=no
/ip pool
add name=pool-bare-metal ranges=10.1.2.2-10.1.2.29
add name=pool-users ranges=10.1.3.50-10.1.3.200
add name=pool-vms-cts ranges=10.1.4.50-10.1.4.200
/ip dhcp-server
add address-pool=pool-users interface=vlan30-users lease-time=5d name=\
    dhcp-users
add address-pool=pool-vms-cts interface=inter-router-link0 lease-time=5d \
    name=dhcp-vlan40 relay=10.1.4.1
add address-pool=pool-bare-metal interface=inter-router-link0 lease-time=5d \
    name=dhcp-vlan20 relay=10.1.2.1
/port
set 0 name=serial0
/routing ospf instance
add disabled=no name=backbonev2 router-id=172.16.0.1
/routing ospf area
add disabled=no instance=backbonev2 name=backbone0v2
/interface bridge port
add bridge=ccr2004-mgmt comment="access for laptop" ingress-filtering=no \
    interface=ether1 internal-path-cost=10 path-cost=10
add bridge=ccr2004-mgmt interface=vlan111-ccr2004-mgmt
/interface list member
add interface=vlan30-users list=ZONE-USERS
add interface=sfp-sfpplus12 list=ZONE-WAN
add interface=ccr2004-mgmt list=ZONE-CCR2004-MGMT
add interface=inter-router-link0 list=LINK-TO-CRS326
/ip address
add address=10.0.0.150/24 comment=WAN interface=sfp-sfpplus12 network=\
    10.0.0.0
add address=10.1.3.1/24 interface=vlan30-users network=10.1.3.0
add address=10.1.1.1/30 interface=ccr2004-mgmt network=10.1.1.0
add address=172.16.255.1/30 interface=inter-router-link0 network=172.16.255.0
add address=172.16.0.1 interface=loopback0 network=172.16.0.1
/ip dhcp-server network
add address=10.1.2.0/27 dns-server=1.1.1.1 gateway=10.1.2.1
add address=10.1.3.0/24 dns-server=1.1.1.1 gateway=10.1.3.1
add address=10.1.4.0/24 dns-server=1.1.1.1 gateway=10.1.4.1
/ip dns
set servers=10.100.40.99,1.1.1.1
/ip firewall address-list
add address=10.1.1.4/30 list=CRS326-MGMT
add address=10.1.2.0/24 list=SERVERs-NET
add address=10.1.4.0/24 list=VMs/LXCs-NET
/ip firewall filter
add action=accept chain=input connection-state=established,related disabled=\
    yes
add action=accept chain=forward comment=\
    "Allowing already established connections" connection-state=\
    established,related disabled=yes
add action=accept chain=input disabled=yes in-interface-list=\
    ZONE-CCR2004-MGMT
add action=accept chain=input disabled=yes in-interface-list=LINK-TO-CRS326 \
    protocol=icmp
add action=accept chain=forward disabled=yes dst-address-list=SERVERs-NET \
    in-interface-list=ZONE-CCR2004-MGMT out-interface-list=LINK-TO-CRS326
add action=accept chain=forward disabled=yes dst-address-list=VMs/LXCs-NET \
    in-interface-list=ZONE-CCR2004-MGMT out-interface-list=LINK-TO-CRS326
add action=accept chain=forward disabled=yes in-interface-list=\
    ZONE-CCR2004-MGMT out-interface-list=ZONE-USERS
add action=accept chain=forward comment=\
    "Accept traffic between CCR2004 Management and CRS326 Management" \
    disabled=yes dst-address-list=CRS326-MGMT in-interface-list=\
    ZONE-CCR2004-MGMT out-interface-list=LINK-TO-CRS326 port=22,8291 \
    protocol=tcp
add action=drop chain=forward comment=\
    "Block traffic from users to networks behind CRS326" disabled=yes \
    in-interface-list=ZONE-USERS out-interface-list=LINK-TO-CRS326
add action=accept chain=forward disabled=yes in-interface-list=ZONE-USERS \
    out-interface-list=ZONE-WAN
add action=accept chain=forward disabled=yes in-interface-list=LINK-TO-CRS326 \
    out-interface-list=ZONE-WAN
add action=accept chain=forward disabled=yes in-interface-list=\
    ZONE-CCR2004-MGMT out-interface-list=ZONE-WAN
add action=drop chain=input disabled=yes
add action=drop chain=forward comment="Dropping all other forward traffic" \
    disabled=yes
/ip firewall nat
add action=masquerade chain=srcnat out-interface=sfp-sfpplus12
/ip route
add disabled=no dst-address=0.0.0.0/0 gateway=10.0.0.1
add dst-address=10.1.1.4/30 gateway=172.16.255.2
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
/routing ospf interface-template
add area=backbone0v2 disabled=no networks=172.16.0.1/32 passive
add area=backbone0v2 disabled=no networks=172.16.255.0/30
add area=backbone0v2 disabled=no networks=10.1.3.0/24 passive
/system clock
set time-zone-name=Europe/Warsaw
/system identity
set name=core-ccr2004
/system resource irq rps
set ether1 disabled=no
```
    
</details>

*   **CRS326**
    *   `crs326-mgmt`, `SVI 115` - `10.1.1.5/30` on `ether1`
    *   `inter-router-link0`, `SVI 100` - `172.16.255.2/30`
    *   `vlan20-bare-metal`, `SVI 20` - `10.1.2.1/27` - untagged `vid 20` on `sfp-sfpplus2`
    *   `vlan40-vms-cts`, `SVI 40` - `10.1.4.1/24` - tagged `vid 40` on `sfp-sfpplus2`
<details>
<summary> config.rsc </summary>
    
```rsc
/interface bridge
add name=loopback0
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
add bridge=main-bridge interface=sfp-sfpplus2 pvid=20
add bridge=main-bridge interface=sfp-sfpplus4
add bridge=main-bridge interface=sfp-sfpplus3
add bridge=main-bridge interface=sfp-sfpplus1 trusted=yes
/interface bridge vlan
add bridge=main-bridge tagged=main-bridge,sfp-sfpplus1 untagged=sfp-sfpplus2 \
    vlan-ids=20
add bridge=main-bridge tagged=main-bridge,sfp-sfpplus1,sfp-sfpplus2 vlan-ids=\
    30
add bridge=main-bridge tagged=main-bridge,sfp-sfpplus1,sfp-sfpplus2 vlan-ids=\
    40
add bridge=main-bridge tagged=main-bridge,sfp-sfpplus1 vlan-ids=100
add bridge=main-bridge tagged=main-bridge untagged=ether1 vlan-ids=115
/interface ethernet switch
set 0 l3-hw-offloading=yes
/ip address
add address=10.1.2.1/27 interface=vlan20-bare-metal network=10.1.2.0
add address=10.1.4.1/24 interface=vlan40-vms-cts network=10.1.4.0
add address=10.1.1.5/30 interface=vlan115-crs326-mgmt network=10.1.1.4
add address=172.16.255.2/30 interface=inter-router-link0 network=172.16.255.0
add address=172.16.0.2 interface=loopback0 network=172.16.0.2
/ip dhcp-relay
add dhcp-server=172.16.255.1 disabled=no interface=vlan20-bare-metal name=\
    vlan20-dhcp-relay
add dhcp-server=172.16.255.1 disabled=no interface=vlan40-vms-cts name=\
    vlan40-dhcp-relay
/ip dns
set servers=1.1.1.1
/ip firewall address-list
add address=10.1.1.4/30 list=CRS326-MGMT
add address=10.1.4.0/24 list=VMs/LXCs
add address=10.1.2.0/27 list=SERVERs
/ip firewall filter
add action=drop chain=input disabled=yes dst-address-list=CRS326-MGMT \
    src-address-list=SERVERs,VMs/LXCs
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
/system clock
set time-zone-name=Europe/Warsaw
/system identity
set name=core-crs326
/system routerboard settings
set enter-setup-on=delete-key
/system swos
set address-acquisition-mode=static identity=SW_CORE_02 static-ip-address=\
    10.10.20.13
```
    
</details>

*   **thinkpad**
    *   `enp0s25` - `10.1.1.2/30`

*   **PVE**
    *   `vmbr0` - `10.1.2.30/27` - untagged `vid 20`, tagged `vid 30, 40`
<details>
<summary> etc/network/interfaces </summary>
    
```bash
auto lo
iface lo inet loopback

iface eno1 inet manual
iface eno2 inet manual
iface eno3 inet manual
iface eno4 inet manual

iface enp6s0 inet manual # 10G uplink to CRS326
iface enp7s0f0 inet manual # 10G vlan 30 access
iface enp7s0f1 inet manual # 10G vlan 30 access

auto vmbr0
iface vmbr0 inet static
address 10.1.2.30/27
gateway 10.1.2.1
bridge-ports enp6s0 enp7s0f0 enp7s0f1
bridge-stp off
bridge-fd 0
bridge-vlan-aware yes
bridge-vids 20 30 40 50
post-up ip link set dev vmbr0 type bridge vlan_filtering 1
post-up bridge vlan del enp6s0 vid 1
post-up bridge vlan del enp7s0f0 vid 1
post-up bridge vlan del enp7s0f1 vid 1
post-up bridge vlan del dev vmbr0 vid 1 self
post-up bridge vlan add dev enp6s0 vid 20 pvid untagged
post-up bridge vlan add dev enp6s0 vid 30 tagged
post-up bridge vlan add dev enp6s0 vid 40 tagged
post-up bridge vlan add dev enp6s0 vid 50 tagged
post-up bridge vlan add dev enp7s0f0 vid 30 pvid untagged
post-up bridge vlan add dev enp7s0f1 vid 30 pvid untagged
post-up bridge vlan add dev vmbr0 vid 20 pvid untagged self    
```
    
</details>


# First issue


