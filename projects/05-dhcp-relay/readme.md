# DHCP Relay Fix

> [!NOTE]
> This is a fix related to my last project. It was [network-modernization](../04-management-network-split)

Basically what I did wrong was that I misunderstood the difference between the `gateway` and `relay` arguments in the DHCP Server configuration.  

The `dhcp-server network` was okay:
```rsc
/ip dhcp-server network
add address=10.1.2.0/27 dns-server=1.1.1.1 gateway=10.1.2.1
add address=10.1.3.0/24 dns-server=1.1.1.1 gateway=10.1.3.1
add address=10.1.4.0/24 dns-server=1.1.1.1 gateway=10.1.4.1
```
However the dhcp-server configuration was wrong:
```rsc
/ip dhcp-server
add address-pool=pool-users interface=vlan30-users lease-time=10m \
name=dhcp-users
add address-pool=pool-vms-cts interface=vlan40-vms-cts \
name=dhcp-vlan40 gateway=10.1.4.1
add address-pool=pool-bare-metal interface=vlan20-bare-metal \
name=dhcp-vlan20 gateway=10.1.2.1
```

The problem here was that the DHCP Server was listening for DHCP Requests on the VLAN Interfaces.
That would work if the SVIs were on the same device.  

However, the SVIs for those two VLANs are not on the CCR2004 but on the CRS326. 
So the relay on the CRS326 was forwarding DHCP Requests on to the SVIs on the CCR2004... which just weren't there, because they were on the CRS326. 
The CCR2004 did not have any IP address in those VLANs, so it just couldn't work as a dhcp-server for them in this way.

The solution I looked up was to properly assign the interface on which the DHCP traffic would come into the CCR2004.  

I wanted to change both of those interfaces to the actual interface on which the DHCP Server should be listening, which was the inter-router link.
Changing the interface for `dhcp-vlan20` was okay but when I wanted to do the same on the `dhcp-vlan40` it gave me an error that two dhcp servers cannot listen on the same interface. 
This actually suprised me because on MikroTik RouterOS Wiki it worked.  

So after some searching I found out that I messed up the `gateway` arugment in the DHCP Server configuration.  

Turns out that when I need a DHCP Server to listen on the same interface, I need to set the `relay` parameter instead of `gateway`.

I fixed the config so it looks like this:
```rsc
/ip dhcp-server
add address-pool=pool-users interface=vlan30-users lease-time=10m \
name=dhcp-users
add address-pool=pool-vms-cts interface=inter-router-link0 \
name=dhcp-vlan40 relay=10.1.4.1
add address-pool=pool-bare-metal interface=inter-router-link0 \
name=dhcp-vlan20 relay=10.1.2.1
```
Now the configuration is valid and VMs and LXCs properly get assigned IPs from the VLAN 40.
The key thing was to set the relay parameter, cause without it, there cannot be two dhcp servers on the same interface.
The VLAN 30 DHCP server can be set up like above because the SVI for the VLAN 30 is on the same device that the DHCP Server is on.   

However since two DHCP Servers need to listen on the same interface, I needed to create a way for them to know from which gateway the DHCP Requests come (VLAN 20 - 10.1.2.1 or VLAN 40 - 10.1.4.1)



