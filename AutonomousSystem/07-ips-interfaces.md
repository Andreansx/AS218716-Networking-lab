# IPs and interfaces

|block|purpose|interface where applicable|
|-:|-:|-:|
|2a06:9801:1514::/48|PA /48|
|2a06:9801:1514:2::/64|Management WG, using /128|wg0|
|2a06:9801:1514:3::/64|iBGP WG, using /128|wg1,wg2|
|2a06:9801:1514:ffff::/64|unique loopbacks, using /128|lo|
|2a06:9801:1514:a::1/128|Anycasted website and Looking Glass|

### wg0 management
|wg interface|AllowedIPs|peer's endpoint interfaces|address|
|:-|:-|:-|:-|
|MacBook wg0|2a06:9801:1514:2::2/128,2a06:9801:1514:2::3/128|wg0 on both VPSes|2a06:9801:1514:2::1/128|
|[edge01.dus.andreansx.net](../edge01.dus.andreansx.net) wg0|2a06:9801:1514:2::1/128|wg0 on MacBook|2a06:9801:1514:2::2/128|
|[edge01.zrh.andreansx.net](../edge01.zrh.andreansx.net) wg0|2a06:9801:1514:2::1/128|wg0 on MacBook|2a06:9801:1514:2::3/128|

### wg1 iBGP
|wg interface|AllowedIPs|peer's endpoint interfaces|address|
|:-|:-|:-|:-|
|[edge01.dus.andreansx.net](../edge01.dus.andreansx.net) wg1|2a06:9801:1514:3::2/128,::/0|wg1 on [edge01.zrh.andreansx.net](../edge01.zrh.andreansx.net)|2a06:9801:1514:3::1/128|
|[edge01.zrh.andreansx.net](../edge01.zrh.andreansx.net) wg1|2a06:9801:1514:3::1/128,::/0|wg1 on [edge01.dus.andreansx.net](../edge01.dus.andreansx.net)|2a06:9801:1514:3::2/128|

> [!IMPORTANT]
> `core01.waw.andreansx.net` must have two separate wireguard interfaces, one for each of the VPSes. Both PoP-A and PoP-B from MikroTik's perspective, must have AllowedIPs set to `::/0`, since the traffic from the entire internet will arrive on MikroTik from one of those two links. However, two peers cannot have overlapping AllowedIPs on one wireguard interface, so PoP-A and PoP-B cannot both at the same time have AllowedIPs set to `::/0`. That is why on MikroTik there will be two wg interfaces, wg2 for connection to PoP-A, and wg3 for PoP-B.   

### wg2 iBGP
|wg interface|AllowedIPs|peer's endpoint interfaces|address|
|:-|:-|:-|:-|
|[edge01.dus.andreansx.net](../edge01.dus.andreansx.net) wg2|2a06:9801:1514:3::13/128,::/0|wg2 on core01.waw.andreansx.net|2a06:9801:1514:3::11/128|
|[edge01.zrh.andreansx.net](../edge01.zrh.andreansx.net) wg2|2a06:9801:1514:3::14/128,::/0|wg3 on core01.waw.andreansx.net|2a06:9801:1514:3::12/128|
|[core01.waw.andreansx.net](../core01.waw.andreansx.net) wg3|2a06:9801:1514:3::11/128,::/0|wg2 on [edge01.dus.andreansx.net](../edge01.dus.andreansx.net/)|2a06:9801:1514:3::13/128|
|[core01.waw.andreansx.net](../core01.waw.andreansx.net) wg2|2a06:9801:1514:3::12/128,::/0|wg2 on [edge01.zrh.andreansx.net](../edge01.zrh.andreansx.net/)|2a06:9801:1514:3::14/128|
