# eBGP setup between Spine-DellEMCS4048-ON and Leaf-vJunosRouter0

For the first time the 10GbE link between the Proxmox host and the Dell EMC S4048-ON will be a dedicated point-to-point routed link rather than a trunk link for a bunch of different VLANs.   

The `vmbr0` configuration is now like this:   
```
auto enp6s0
iface enp6s0 inet manual
        mtu 9216

auto vmbr0
iface vmbr0 inet manual
        bridge-ports enp6s0
        bridge-stp off
        bridge-fd 0
        mtu 9216

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

After booting up the Leaf-vJunosRouter0 I could see that there correctly are two interfaces in the up state:   
```Junos 
--- JUNOS 25.4R1.12 Kernel 64-bit  JNPR-15.0-20251024.861cae5_buil
aether@vJunosRouter0> show interfaces terse 
Interface               Admin Link Proto    Local                 Remote
ge-0/0/0                up    up
ge-0/0/0.0              up    up   inet    
                                   multiservice
lc-0/0/0                up    up
lc-0/0/0.32769          up    up   vpls    
pfe-0/0/0               up    up
pfe-0/0/0.16383         up    up   inet    
                                   inet6   
pfh-0/0/0               up    up
pfh-0/0/0.16383         up    up   inet    
pfh-0/0/0.16384         up    up   inet    
ge-0/0/1                up    up
ge-0/0/1.16386          up    up  
ge-0/0/2                up    down
ge-0/0/2.16386          up    down
ge-0/0/3                up    down
ge-0/0/3.16386          up    down
...
```

The `ge-0/0/0` interface corresponds to `net1` vNIC which is connected to the `enp6s0` physical interface. 
The `ge-0/0/1` interface is `net2` vNIC connected to `vmbr1`.   

I set the correct MTU on the interfaces in Leaf-vJunosRouter0:   
```Junos
[edit]
aether@vJunosRouter0# set interfaces ge-0/0/0 mtu 9216 

[edit]
aether@vJunosRouter0# set interfaces ge-0/0/1 mtu 9216    

[edit]
aether@vJunosRouter0# commit 
commit complete
```

I will be working now mostly on `ge-0/0/0` as it is the interface connected to Spine-DellEMCS4048-ON.   

I deleted the SVIs and set an IP address on the `Te1/14` interface:   
```OS9

Spine-DellEMCS4048-ON#conf
Spine-DellEMCS4048-ON(conf)#no int vl 50
Spine-DellEMCS4048-ON(conf)#no int vl 40
Spine-DellEMCS4048-ON(conf)#no int vl 60
Spine-DellEMCS4048-ON(conf)#interface Tengigabitethernet 1/14
Spine-DellEMCS4048-ON(conf-if-te-1/14)#no switchport 
Spine-DellEMCS4048-ON(conf-if-te-1/14)#ip ad 172.16.255.4/31
% Warning: Use /31 mask on non point-to-point interface cautiously.
```



