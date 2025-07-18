# VM 100 - zenith (FreeBSD 14.3)

A general-purpose FreeBSD virtual machine for testing system administration tasks, ZFS experiments, and hosting lightweight services within the homelab.

### I will use this VM as a part of [unbound homelab](https://github.com/andreansx/unbound-homelab) project.

## Network
- **hostname:** `freebsd-server`  
- **bridge:**   `vmbr0`  
- **VLAN Tag:** `20`  
- **IP Address:** Acquired via DHCP from `10.10.20.0/24`. *(DHCP server running on [ccr2004](../../ccr2004/config.rsc))*

##  Services Hosted

*Currently, no persistent services are running.*

