# OSPF Area 0 routers locked in "Init" state 

Recently I encountered an issue with OSPF backbone area between my core routers.  

The first thing I saw was that I wasn't able to connect to my PVE host.  

I was using my lapotp (`10.1.1.2/30`) connected to `ether1` on CCR2004 (`10.1.1.1/30`). 
There is OSPF running between this CCR2004 and the CRS326 on their inter-router link (`172.16.255.0/30`) interfaces.
The VLAN 20 where the PVE host has it's web panel, is available through the `sfp-sfpplus2`, SVI 20 interface on the CRS326. 


