## Plan for improved IP & VLAN addressation

### Current subnets looks like this

- **10.10.10.0/24** - Management
- **10.10.20.0/24** - Bare-metal
- **10.10.30.0/24** - Users
- **10.10.40.0/24** - VMs/CTs

This configuration is really simple. However, it wastes a lot of addresses because of the `/24` subnets. And this also makes a great oppurtunity to learn  VLSM.  

To adress the issue of wasting addresses and also to create a bit more advanced network than typical `/24`, the new architecture will be based on VLSM. My lab will use a `10.100.0.0/16` block as it's main range. The third octet of the IP address will correspond to the VLAN ID for better readability.  

### New plan:


- **10.100.10.0/28** - Management - 14 hosts, completely enough for my lab
- **10.100.20.0/28** - Bare-metal - 14 hosts, also completely enough
- **10.100.30.0/24** - Users, here I will leave `/24` to allow for a large DHCP pool.
- **10.100.40.0/24** - VMs and CTs, also leaving a bigger subnet to allow for a big numer of Proxmox resources