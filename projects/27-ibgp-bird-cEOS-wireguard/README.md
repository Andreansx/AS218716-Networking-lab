### Here i wanted to do something that will prove that my intended own AS setup is possible. Meaning I'll establish an iBGP session between an cEOS container and a VPS with BIRD. 

The iBGP connection will be established through a wireguard tunnel. Though EOS does not support Wireguard, so I will set a lightweight Alpine linux container next to cEOS and route all traffic from and out of the cEOS through the Alpine container.

Both the cEOSarm and Alpine containers will be launched with Containerlab in Orbstack on my Mac.   

Base Alpine does not have wireguard built in, so for that, there's this simple dockerfile, that allows me to make a custom alpine build, with wireguard included.   

> [!NOTE]
> The latest and correct version of this is in [./Dockerfile](./Dockerfile).
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

I wrote a simple config for the Alpine:
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

> [!NOTE]
> This is outdated, as the BGP session will actaully be between loopbacks, so the BGP packets from cEOS will originate from 10.0.99.2. I didn't want to delete this, but keep in mind that this has changed.   


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

> [!NOTE]
> This has also changed. The latest and correct version of this file is in [topology.clab.yml](./topology.clab.yml). 
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


I added `startup-config: ceos.partial.cfg` to the clab file. I then ran `clab destroy --cleanup` and `clab deploy --reconfigure`.   

`ceos.partial.cfg` instead of `ceos.startup.cfg` makes it so I don't have to keep the entire system config in that file so in there I can keep only the things that I want to explicitly configure myself. 

In the `ceos.partial.cfg` file I wrote down the simplest config for now   

> [!NOTE]
> This is the version before a fix with `no switchport`. See below.   
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

Ping then went through, both from cEOS to Alpine's end of veth and to VPS' loopback, with visibly longer response time.   

![scrn3](./scrn3.png)   

### AllowedIPs

Now I wanted to talk about cryptokey routing, as honestly its still a bit hard for me to get a grasp on the whole AllowedIPs thing.   

I won't explain the whole way in which the AllowedIPs works, but I wanted to state why the current AllowedIPs lists on both sides are the way they are now.   

But shortly, there are two lookups, one on a leaving packet by the DST, and the second one on an arriving packet by SRC.   

On the VPS the AllowedIPs look like this
```
AllowedIPs = 10.99.99.2/32, 10.0.99.2/32, 10.10.99.0/30
```

And on the Alpine this list looks like this
```
AllowedIPs = 10.99.99.1/32, 10.0.99.1/32
```

The VPS has to allow more IPs, because behind it's only peer (Alpine) there is also cEOS.  
Both sides need to allow the peer's loopback address. Alpine allows 10.0.99.1/32 and VPS allows 10.0.99.2/32. 
Both sides allow also only the peer's IP inside the wg tunnel itself. VPS allows only 10.99.99.2/32 and Alpine allows only 10.99.99.1/32.  
It would be possible to theoretically input 10.99.99.0/30, but that breaks the concept that wireguard makes possible thanks to cryptokey routing. If I wrote 10.99.99.0/30 on Alpine's side, it would allow incoming packets from the VPS which state that they are originating from the Alpine itself.   
Also we shouldn't enter the same prefix on both peers on the same interface. Meaning, we have two peers on wg0, and we shouldn't enter the same prefix in the AllowedIPs section for both those peers, as the AllowedIPs relate strictly to the cryptographic identity of the peer.  
There is no preference here, the radix trie just has a only single record for that subnet (single IP to public key relation). So basically the last write wins.    
There is basically one trie like that for a wg interface, it's the same for all peers on that interface and it works just like LPM in a FIB but the output is not a next hop but rather the cryptographic identity of a peer.   

Now a crucial thing. The iBGP session is actually loopback-to-loopback, which means, the `10.10.99.0/30` prefix is not really needed in AllowedIPs on VPS' side.   
The iBGP session would in fact establish. But for example, pings for testing the MTU, would not get back from the VPS to the cEOS. 
That is because in it's default behavior, the AllowedIPs list also makes wg-quick install the routes to those prefixes in the FIB, but Wireguard itself does never touch the FIB.   
So if I removed 10.10.99.0/30 from AllowedIPs on the VPS, a packet originating from 10.10.99.2 would arrive on Alpine, it would get encapsulated, sent to VPS, thus changing it SRC to Alpine's CGNATed public IP (cause Im behind CGNAT) and DST to VPS' public IP, then it arrives on VPS, gets decapsulated, Wireguard looks at the SRC of the decapsulated packet, sees 10.10.99.2, notices, that this is not even an allowed prefix, from the peer from which it received the packet from, and silently drops it.   
That is the first issue, but let's say that the packet somehow got through the trie, and got into the networking stack of the VPS.
The VPS then wants to send a response to the ping, it sets 10.10.99.2 as the DST, and then drops it, because it does not know any route to 10.10.99.2.   
This is of course fixable, by manually adding `ip route 10.10.99.0/30 dev wg0` on the VPS, but as I said before, the packet would not even be allowed to enter the VPS' IP stack, because it originates from an IP that is not allowed to arrive from VPS' peer (Alpine).   

So BGP itself does not need 10.10.99.0/30 included in AllowedIPs on the VPS. 
But I am in fact leaving 10.10.99.0/30 in VPS' AllowedIPs, not for BGP but for reachability and traceroute.   


### MTU
