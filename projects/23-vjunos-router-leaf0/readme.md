# eBGP setup between Spine-DellEMCS4048-ON and Leaf-vJunosRouter0

For the first time the 10GbE link between the Proxmox host and the Dell EMC S4048-ON will be a dedicated point-to-point routed link rather than a trunk link for a bunch of different VLANs.   

The `vmbr0` configuration is now like this:   
```
auto vmbr0
iface vmbr0 inet manual
        bridge-ports enp6s0
        bridge-stp off
        bridge-fd 0
```
It's not VLAN-aware and has one physical interface bridged.   

The `vmbr0` linux bridge along with `enp6s0` have MTU set to 9216 accordingly to best practices regarding 10GbE links.   

![mtu](./mtu.png)   

Actually the entire underlay has MTU 9216 set.    

For example on the Spine-DellEMCS4048-ON:   
```OS9 
Spine-DellEMCS4048-ON#sh interfaces Tengigabitethernet 1/1
TenGigabitEthernet 1/1 is up, line protocol is up
Hardware is DellEMCEth, address is e4:f0:04:c8:b2:3f
    Current address is e4:f0:04:c8:b2:3f
Non-qualified pluggable media present, SFP+ type is 10GBASE-SR
    Medium rate is unknown, Wavelength is 850nm
    SFP+ receive power reading is -2.3950dBm
    SFP+ transmit power reading is -2.8133dBm
Interface index is 2097156
Internet address is 172.16.255.3/31
Mode of IPv4 Address Assignment : MANUAL
DHCP Client-ID(61): e4f004c8b23f
MTU 9216 bytes, IP MTU 9198 bytes
LineSpeed 10000 Mbit
...
```
And on the border-leaf-ccr2004:   
```rsc
1 R  name="sfp-sfpplus1" default-name="sfp-sfpplus1" mtu=9216 l2mtu=9216 
      mac-address=08:55:31:A7:92:16 orig-mac-address=08:55:31:A7:92:16 arp=enabled 
      arp-timeout=auto loop-protect=default loop-protect-status=off 
      loop-protect-send-interval=5s loop-protect-disable-time=5m auto-negotiation=yes 
      advertise=10M-baseT-half,10M-baseT-full,100M-baseT-half,100M-baseT-full,1G-baseT-half,1G-
          baseT-full,1G-baseX,2.5G-baseT,2.5G-baseX,5G-baseT,10G-baseT,10G-baseSR-LR,10G-
          baseCR 
      tx-flow-control=off rx-flow-control=off bandwidth=unlimited/unlimited switch=switch1 
      sfp-rate-select=high sfp-ignore-rx-los=no sfp-shutdown-temperature=95C 
```



