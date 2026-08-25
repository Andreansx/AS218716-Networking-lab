# Experimenting with filters on BIRD

Here I just wanted to run a couple of BIRD instances and mess around with how the whole `filter` and `function` blocks work.   

There are two Autonomous Systems here, AS65000 with two routers (bird1 and bird2) connected by iBGP and AS65001 with one router (telekom1), and both are connected with eBGP.   

I kind of did all that without documenting this so I will mostly just explain the specific interesting things rather than the whole entire topology.   

Point-to-point link between bird1 and bird2 uses the 2001:db8:beef::/127 network. Bird1 on eth1 has `2001:db8:beef::/127` and bird2 on eth1 has `2001:db8:beef::1/127`.   

Bird2 and telekom1 link uses `2001:db8:beef::2/127`. bird2 on eth2 has `2001:db8:beef::2/127` and telekom1 on eth1 has `2001:db8:beef::3/127`.

loopbacks are like this 
|router|lo|
|-:|-:|
|bird1|2001:db8:dead::1/128|
|bird2|2001:db8:dead::2/128|
|telekom1|2001:db8:abcd::1/128|

Advertised /48s are:
|router|prefix|
|-:|-:|
|bird1|2001:db8:1111::/48|
|bird2|2001:db8:2222::/48|
|telekom1|2001:db8:3333::/38|

So basically every router has `route PREFIX blackhole;` in `protocol static`.   

`topology.clab.yml` may look long but it is basically the same thing three times:
```yaml
name: birdtest1
topology:
  nodes:
    bird1:
      kind: linux
      image: bird1:local
      binds:
        - bird1.conf:/etc/bird.conf
      sysctls:
        net.ipv4.ip_forward: 1
        net.ipv6.conf.all.forwarding: 1
        net.ipv6.conf.all.disable_ipv6: 0
      exec:
        - ip -6 addr add 2001:db8:dead::1/128 dev lo
        - ip -6 addr add 2001:db8:beef::/127 dev eth1
        - bird -c /etc/bird.conf
    bird2:
      kind: linux
      image: bird1:local
      binds:
        - bird2.conf:/etc/bird.conf
      sysctls:
        net.ipv4.ip_forward: 1
        net.ipv6.conf.all.forwarding: 1
        net.ipv6.conf.all.disable_ipv6: 0
      exec:
        - ip -6 addr add 2001:db8:dead::2/128 dev lo
        - ip -6 addr add 2001:db8:beef::1/127 dev eth1
        - ip -6 addr add 2001:db8:beef::2/127 dev eth2
        - bird -c /etc/bird.conf
    telekom1:
      kind: linux
      image: bird1:local
      binds:
        - telekom1.conf:/etc/bird.conf
      sysctls:
        net.ipv4.ip_forward: 1
        net.ipv6.conf.all.forwarding: 1
        net.ipv6.conf.all.disable_ipv6: 0
      exec:
        - ip -6 addr add 2001:db8:abcd::1/128 dev lo
        - ip -6 addr add 2001:db8:beef::3/127 dev eth1
        - bird -c /etc/bird.conf
  links:
    - endpoints: ["bird1:eth1","bird2:eth1"]
    - endpoints: ["telekom1:eth1","bird2:eth2"]
```
The `bird1:local` image is built from this Dockerfile:
```Dockerfile
FROM alpine:3.22
RUN apk add --no-cache bird iputils iproute2
CMD ["sleep", "infinity"]
```

