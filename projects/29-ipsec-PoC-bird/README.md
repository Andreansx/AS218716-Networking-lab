# I wanted to do the same thing as [here](../28-bird-filters-upstream-sim/) but with IPSec between BIRD instances instead of Wireguard.   
Wireguard is widely used now, but IPSec is more enterprise and more certified in ways that I haven't really looked deep into, but basically it's the industry standard, and it is actually supported on a wider range of systems and hardware than WG.   
Also the hardware is important, IPSec has hardware accelerators but Wireguard does not, so Wireguard just takes a lot of CPU power to encrypt and decrypt the traffic when there is a lot of it but IPSec makes encryption in real time possible on 100Gbps links thanks to hardware accelerators, cause in software it is actually slower than Wireguard's ChaCha20-Poly1305.    

I wanted at first to run this in Docker in Orbstack VM, so I wrote the simplest `topology.clab.yml` for now:   
```
name: ipsec0
topology:
  nodes:
    r1:
      kind: linux
      image: bird1:local
      binds:
        - bird1.conf:/etc/bird.conf
        - clab-ipsec0/authorized_keys:/root/.ssh/authorized_keys:ro
      sysctls:
        net.ipv4.ip_forward: 1
        net.ipv6.conf.all.forwarding: 1
        net.ipv6.conf.all.disable_ipv6: 0
      exec:
        - bird -c /etc/bird.conf
        - /usr/sbin/sshd
```
And a Dockerfile:
```
FROM alpine:3.22
RUN apk add --no-cache bird tcpdump iputils strongswan iproute2 openssh && ssh-keygen -A
CMD ["sleep", "infinity"]
```

But it turns out, that the orbstack kernel does not have the necessary modules for xfrm-type interfaces, so only policy-based encryption would work.   
Running this on r1:
```
r1:~# ip link add ipsec0 type xfrm dev lo if_id 1
Error: Unknown device type.
```
Shows that the xfrm type does not exist. 
Modprobe shows that esp6 module does exist, but the xfrm_interface does not: 
```
# sudo modprobe esp6
# sudo modprobe xfrm_interface
modprobe: FATAL: Module xfrm_interface not found in directory /lib/modules/7.0.14-orbstack-00380-ga7e0a2dc9535
```

This does not seem like such big of a problem, cause I would just set up a policy to encrypt whatever traffic is forwarded from 2001:db8:abcd:10::/64 to 2001:db8:abcd:99::/64, soo the kernel captures and encrypts the traffic basing on a policy, not on routing itself.
But BIRD is what it's important for. BIRD to establish a BGP session, needs an interface and an address.
I mean policy-based encryption would also provide that, just need an address on the loopback and a BGP session between physical addresses. BGP packets will get encrypted by policy, and the session will establish.
The problem is with the place that the decision about encryption takes place. In policy-based it's a SPD, which is a list of selectors which look at `src/dst`. But those selectors need to be provided in advance. Routing table is not even looked at in the process of this particular decision, as it is looked at before that.  
So every prefix learned by BIRD would need a respective SPD rule, so the crypto and control planes are falling apart from each other after first `UPDATE` from BGP.   

In policy-based encryption, there is a packet in the network stack, kernel looks at the FIB, then after selecting the NH, kernel looks at the SPD and decides whether to encrypt it by looking at its source and destination IPs and comparing them to the prefixes in selectors. BIRD cannot touch the selectors and does not import them to itself in any way.   

In route-based encryption the route from BGP does steer the encryption decision. Because the Security Association and policy are bound to `if_id`, whatever FIB sends to `ipsec0`, gets into ESP so it gets encrypted.   

So policy-based encryption without xfrm interfaces is possible in Orbstack, but the thing that is the core of this PoC, which is route-based encryption, is not possible because of the lack of the necessary modules in Orbstacks kernel.   
