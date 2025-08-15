# Troubleshooting OSPF, L2 loop and PVE network configuration

In this case study I would like to talk about a massive issue that happened to me in my lab. 
It took down the entire OSPF Instance and completly disabled access from two ends of my network to each other.  

First I would like to state every IP address for clarity.   

*   **CCR2004**
    *   `ccr2004-mgmt`, `SVI 111` - `10.1.1.1/30` on `ether1`
    *   `inter-router-link0`, `SVI 100` - `172.16.255.1/30` 

*   **CRS326**
    *   `crs326-mgmt`, `SVI 115` - `10.1.1.5/30` on `ether1`
    *   `inter-router-link0`, `SVI 100` - `172.16.255.2/30`
    *   `vlan20-bare-metal`, `SVI 20` - `10.1.2.1/27` - untagged `vid 20` on `sfp-sfpplus2`
    *   `vlan40-vms-cts`, `SVI 40` - `10.1.4.1/24` - tagged `vid 40` on `sfp-sfpplus2`

*   **thinkpad**
    *   `enp0s25` - `10.1.1.2/30`

*   **PVE**
    *   `vmbr0` - `10.1.2.30/27` - untagged `vid 20`, tagged `vid 30, 40`


