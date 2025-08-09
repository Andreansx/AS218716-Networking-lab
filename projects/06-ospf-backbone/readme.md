# OSPF Backbone

Here I will cover the process in which I implement OSPF Dynamic Routing Protocol on an inter-router link between my two Core Routers.

## Topology

![topology](./ospf.png)

### Hardware

*   **CCR2004-1G-12S+2XS**
    *   `loopback0` - 172.16.0.1/32
    *   `inter-router-link0` - 172.16.255.1/30
*   **CRS326-24S+2Q+RM**
    *   `loopback0` - 172.16.0.2/32
    *   `inter-router-link0` - 172.16.255.2/30

> [!NOTE]
> I will use IPs from `loopback0` interfaces as a Router ID in the OSPF Configuration.


So basically what I wanted to achieve, was to swap out static routes for Dynamic Routing using **OSPF**.  

The CRS326 will advertise VLANs 20 and 40, bacause it has SVIs in them. And the CCR2004 will advertise VLAN 30. All communication will be routed through a inter-router link with a network address of `172.16.255.0/30`.  

First thing to do was to assign a loopback IP address. Using loopbacks as Router IDs is a more failure-proof way of assigning a RID because if I were to assign a RID based on a physical interface then if that interface would go down, then the presence of this router would just disappear.  

So RID for CCR2004 will be `172.16.0.1` and RID for CRS326 will be `172.16.0.2`.  

To do this I just created a bridge without any interfaces so it won't be connected to anything and assigned it an IP address.

CCR2004:
```rsc
/interface bridge/
add name=loopback0
/ip address/
add address=172.16.0.1/32 interface=loopback0
```
CRS326:
```rsc
/interface bridge/
add name=loopback0
/ip address/
add address=172.16.0.2/32 interface=loopback0
```
Then I could get into the actual OSPF configuration.  
First I created a new instance. 

On the CCR2004:
```rsc
/routing ospf instance
add name=backbonev2 version=2 router-id=172.16.0.1
```
Then I created a new area and assigned the networks that I wanted to be advertised by OSPF. At first I added only loopbacks and the inter-router link network.
```rsc
/routing ospf area 
add instance=backbonev2 area-id=0.0.0.0 name=backbone0v2
/routing ospf interface-template
add area=backbone0v2 networks=172.16.255.0/30 passive
add area=backbone0v2 networks=172.16.0.1/32 passive
```
Then The same thing on the CRS326:
```rsc
/routing ospf instance
add name=backbonev2 router-id=172.16.0.2
/routing ospf area
add instance=backbonev2 area-id=0.0.0.0 name=backbone0v2
/routing ospf interface-template
add area=backbone0v2 networks=172.16.0.2/32 passive
add area=backbone0v2 networks=172.16.255.0/30
```



