### Here i wanted to do something that will prove that my intended own AS setup is possible. Meaning I'll establish an iBGP session between an cEOS container and a VPS with BIRD. 

The iBGP connection will be established through a wireguard tunnel. Though EOS does not support Wireguard, so I will set a lightweight Alpine linux container next to cEOS and route all traffic from and out of the cEOS through the Alpine container.

Both the cEOSarm and Alpine containers will be launched with Containerlab in Orbstack on my Mac.   

Base Alpine does not have wireguard built in, so for that, there's this simple dockerfile, that allows me to make a custom alpine build, with wireguard included.   

```Dockerfile
FROM alpine:3.22
RUN apk add --no-cache wireguard-tools iproute2 iptables bash tcpdump
```
And then i built it with this
```bash
sudo docker build -t alpine-wg:3.22 .
```
cause without that, i would have to do `apk add` after every launch.   

So first i wanted to set up the wg container by myself manually and only after confirming it works, set it up in clab file.   

So in the most simple way I run the container with `sudo docker run -d --name wg --cap-add NET_ADMIN alpine-wg:3.22 sleep infinity`    
`--cap-add NET_ADMIN` allows the container to create the wg0 interface and add addresses and routes.   


![scrn0](./scrn0.png)   

10.0.99.0/24 is for loopbacks, 10.99.99.0/24 is for wireguard links, 10.10.99.0/24 is for veth between the cEOS and wg.

I wrote a simple config for the cEOS:
```conf
[Interface]
Privatekey = ...
Address = 10.99.99.2/30

[Peer]
Publickey = ...
AllowedIPs = 10.99.99.1/30, 10.0.99.1/32
Endpoint = ...:51820
PersistentKeepAlive = 25
```


As for the VPS, I wrote another config, also super simple:
```
[Interface]
Privatekey = ...
Address = 10.99.99.1/30
[Peer]
Publickey = ...
AllowedIPs = 10.99.99.2/32, 10.0.99.2/32, 10.10.99.1/32
```

In Wireguard, the AllowedIPs is not a simple filter, as it has a meaning in the cryptography, and the BGP packets will originate not from Alpine/wg container's own wg0 interface, but rather from the cEOS' side of the veth link connecting the cEOS to wg. So the IP address, from which the packets will arrive in the tunnel, will be 10.10.99.1, not 10.99.99.1.    
So the config on the VPS has to allow the IP addresses on the veth link between the wg and cEOS.
This config allows 10.99.99.2/32 (cEOS' side of wireguard tunnel), 10.0.99.2/32 (cEOS' loopback) and 10.10.99.1/32 (cEOS' side of wg<->cEOS veth).

I set both those configs on wg and on the VPS. On the VPS i ran `sudo systemctl restart wg-quick@wg0` and on the wg i ran `wg-quick up wg0`.   
I soon noticed that there was no handshake, and running `wg show` revealed the issue.   

![screenshot 1](./scrn1.png)

I didn't set the proper listening port so it chose a random one. After adding `ListenPort = 51820` in `[Interface]` section on VPS the handshake went through.   

![screenshot 2](./scrn2.png)   


Now I wanted to get into the actual iBGP between cEOS and BIRD on VPS.   
I wrote a simple clab file, cause it's easier to deploy cEOS with clab than with bare docker, as cEOS does require `--privileged`, `CEOS=1` and things like that. But clab does all that after I write `kind: ceos` in the clab file.   

```yml
name: ibgp-wg

topology:
  nodes:
    ceos:
      kind: ceos
      image: ceos:4.35.3F

    alpine:
      kind: linux
      image: alpine-wg:3.22
      cmd: sleep infinity
      binds:
        - wg-eos.conf:/etc/wireguard/wg0.conf
      sysctls:
        net.ipv4.ip_forward: 1
      exec:
        - ip link set eth1 up
        - ip addr add 10.10.99.2/30 dev eth1
        - wg-quick up wg0
        - ip route add 10.0.99.2/32 via 10.10.99.1

  links:
    - endpoints: ["ceos:eth1", "alpine:eth1"]
```

And also clab connects the two containers easier than bare docker, cause with bare Docker its necessary to manually create a veth in the two containers and that does require knowing the PIDs of the containers.   

On the VPS i had to add the loopback address that I wanted it to use 
```bash
sudo ip addr add 10.0.99.1/32 dev lo
```
Also in wg-vps.conf in section AllowedIPs, I changed `10.10.99.1/32` to `10.10.99.0/30`.  

The reason for that, is to make Alpine's kernel not silently drop the decapsulated packets. Cause the packets that would go from VPS to Alpine and then from Alpine to cEOS will originate from 10.10.99.2, and that address is not included in 10.10.99.1/32 of course, so those packets would get dropped.   
The iBGP sessions between loopbacks would in fact work, but for example pings from the transit network (`10.10.99.0/30`) would get dropped by Alpine's kernel.

I added `startup-config: ceos.pertial.cfg` to the clab file. I then ran `clab destroy --cleanup` and `clab deploy --reconfigure`.   

`ceos.partial.cfg` instead of `ceos.startup.cfg` makes it so I don't have to keep the entire system config in that file so in there I can keep only the things that I want to explicitly configure myself. 

In the `ceos.partial.cfg` file I wrote down the simplest config for now   
```cfg
interface Ethernet1
  ip address 10.10.99.2/30
interface Loopback0
  ip address 10.0.99.2/32
ip routing
ip route 10.0.99.1/32 10.10.99.1
```
I'll add the iBGP part in a while, along with iBGP on BIRD (which is on the VPS).   

Also I changed the addresses a bit, so the last octets of the IPv4 addresses are clearer. 


|where|.1|.2|
|-:|-:|:-|
|loopbacks 10.0.99.0/24|VPS|cEOS|
|wg tunnel 10.99.99.0/30|VPS|Alpine|
|veth 10.10.99.0/30|Alpine|cEOS|

I tried to ping 10.10.99.2 from cEOS but of course it didn't work, cause I forgot that interfaces are switchports by default in EOS.  

So i added `no switchport` to the Ethernet1 section. 
```
