# OSPF Backbone

Here I will cover the process in which I implement OSPF Dynamic Routing Protocol on an inter-router link between my two Core Routers.

### Hardware

*   **CCR2004-1G-12S+2XS**
    *   `loopback0` - 172.16.0.1/32
    *   `inter-router-link0` - 172.16.255.1/30
*   **CRS326-24S+2Q+RM**
    *   `loopback0` - 172.16.0.2/32
    *   `inter-router-link0` - 172.16.255.2/30

> [!NOTE]
> I will use IPs from `loopback0` interfaces as a Router ID in the OSPF Configuration.

