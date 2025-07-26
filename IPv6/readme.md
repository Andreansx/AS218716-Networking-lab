# IPv6 Documentation

## Goal

The main goal is to gain access to a routed /64 or /48 IPv6 address block for my lab for education reasons. Preferably from **Hurricane Electric Free IPv6 Tunnel Broker**.  
Knowledge of IPv6 is a appreciated thing today ( or so I've heard ) in HPC environments, AS networks etc.  
By having access to a IPv6 addressation I would be able to practically learn a gigantic number of things like dynamic routing ( OSPFv3, BGP ) and hosting services available globally through IPv6.
This would also be a comeback to the vanilla ARPANET concepts.

# Situation

This might be the most important part of this documentation. My lab network is actually behind a **Triple NAT**.  
**First NAT** is done in my ISPs (Victor, AS198604) network. This is the only public IP address in this whole situation.   
Next, my ISP-provided router has a WAN interface with assigned IP address **192.168.254.251**. This is the place the **second NAT** takes place. As you can see that is a private address, which means that this is a CGNAT scenario.  
ISP-provided router provides only one LAN network ( 10.0.0.0/24 ). My core router is connected through a SFP RJ45 on interface `sfp-sfpplus12` and a copper ethernet cable to the eth4 port on the ISP-provided router.  
WAN interface address on my core router is 10.0.0.150/24. Here is the **third NAT** My lab is in a 10.100.0.0/16 block. I divide this block between VLANs. For example management VLAN ID 10 with addressation block 10.100.10.0/28.  

  
The ISPs CGNAT IP address is not ICMP-pingable. It doesn't return the pings from outside.  

This makes it impossible for me to setup a 6to4 tunnel, because it requires a reachable IPv4 endpoint capable of responding to ICMP requests and forwarding traffic on port 41 ( GRE protocol ).  

