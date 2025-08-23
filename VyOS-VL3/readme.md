# VyOS-VL3 vRouter

This is the document which covers the purpose and configuration of this vitrual router.  

## Interfaces

This router has three vNICs:
*   `net0`, `eth0` - `vmbr0`
*   `net1`, `eth1` - `vmbr1`
*   `net2`, `eth2` - `vmbr2`

# Purpose

So this router is a part of one of my projects and this one is about modernizing vlan 30 access through a dual-port 10GbE RJ45 NIC mounted in my Dell PowerEdge R710.  

You might want to read [VLAN 30 Access with Dual Port NIC](../projects/02-vlan30-access-without-sfp-transreceivers/readme.md) first, as it covers the origin of this idea and the first solution to it.   

However, this configuration was really fragile as you can read in [OSPF and L1 loop](../projects/11-ospf-and-l2-loop).
A simple loop caused the whole OSPF instance to go down, as it flooded the entire network with like 5 milion packets per second.   


