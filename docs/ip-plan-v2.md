## Plan for improved IP & VLAN addressation

### Current subnets looks like this

- **10.10.10.0/24** - Management
- **10.10.20.0/24** - Bare-metal
- **10.10.30.0/24** - Users
- **10.10.40.0/24** - VMs/CTs

This configuration is really simple. However, it wastes a lot of addresses because of the `/24` subnets. And this also makes a great oppurtunity to learn  VLSM