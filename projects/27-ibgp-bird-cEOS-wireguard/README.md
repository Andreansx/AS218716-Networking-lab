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

![](./scrn1.png)   

I didn't set the proper listening port so it chose a random one. After adding `ListenPort = 51820` in `[Interface]` section on VPS the handshake went through.   

![](./scrn2.png)
