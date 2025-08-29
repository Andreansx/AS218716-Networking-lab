# MikroTik CCR2004

The CCR2004-1G-12S+2XS is the Edge router in my lab   

Its running latest stable RouterOS v7.19.4   

Between this router and the CRS326 there are two eBGP Sessions running.  

Management is available on `10.1.1.1/30` IP address through the `ether1` interface.  

The CCR2004 ASN is 65000.

# Physical links

*   `ether1` - ThinkPad T450s for management.
*  `sfp-sfpplus1` - eBGP-Link-0 to CRS326 `sfp-sfpplus1`
*  `sfp-sfpplus11` - eBGP-Link-1 to CRS326 `sfp-sfpplus24`
*  `sfp-sfpplus12` - WAN interface, link to ISP-provided router.






