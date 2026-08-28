# Some experimenting with IPSec IKEv2 and its behaviour 

IPSec is honestly so damn complex and it's hard for me to get a grasp on IKEv2 now. I mean as of now I somewhat get how does IKE_SA_INIT and IKE_AUTH work a bit, but there are so many specific details, and also the MTU can change depending on the cipher and other stuff. 
In wireguard it's 60 or 80 bytes depending on the usage of IPv4 or IPv6 and that is it.  

As I said [here](../29-ipsec-PoC-bird/), it is not possible to use route-based encryption with xfrm interfaces in Alpine Linux containers in Docker in Orbstack on Apple Silicon, because the Orbstack's kernel does lack the necessary `xfrm_interface` module.   
BUT policy-based does work, and basically a lot of stuff with IKE and its behaviour can be learned there, as IPSec generally works, just not with the VTI way.   

`topology.clab.yml` is fairly simple, as always:   
```
name: ipsecpolicybasedexp
topology:
  nodes:
    r1:
      kind: linux
      image: bird1:local
      sysctls:
        net.ipv4.ip_forward: 1
        net.ipv6.conf.all.forwarding: 1
        net.ipv6.conf.all.disable_ipv6: 0
      binds:
        - r1.ipsec.conf:/etc/ipsec.conf
        - strongswan.conf:/etc/strongswan.conf
        #- clab-ipsecpolicybasedexp/authorized_keys:/root/.ssh/authorized_keys:ro
        - ipsec.secrets:/etc/ipsec.secrets
      exec:
        - ip addr add 2001:db8:abcd:10::/127 dev eth1
        - ip addr add 2001:db8:abcd:1111::1/64 dev lo
        - ipsec restart
        - /usr/sbin/sshd
    r2:
      kind: linux
      image: bird1:local
      sysctls:
        net.ipv4.ip_forward: 1
        net.ipv6.conf.all.forwarding: 1
        net.ipv6.conf.all.disable_ipv6: 0
      binds:
        - r2.ipsec.conf:/etc/ipsec.conf
        - strongswan.conf:/etc/strongswan.conf
        #- clab-ipsecpolicybasedexp/authorized_keys:/root/authorized_keys:ro
        - ipsec.secrets:/etc/ipsec.secrets
      exec:
        - ip addr add 2001:db8:abcd:10::1/127 dev eth1
        - ip addr add 2001:db8:abcd:2222::1/64 dev lo
        - ipsec restart
        - /usr/sbin/sshd
  links:
    - endpoints: ["r1:eth1","r2:eth1"]
```
The thing with `clab-ipsecpolicybasedexp/authorized_keys:/root/.ssh/authorized_keys:ro` breaks after `clab destroy --cleanup` so i commented it for now.   
I mount three files for each node.    
`r*.ipsec.conf` is the core ipsec config file. `strongswan.conf` contains this:   
```
charon {
    filelog {
        charon {
            path = /var/log/charon.log
            time_format = %b %e %T
            ike = 2
            knl = 2
            cfg = 2
            default = 1
            append = yes
            flush_line = yes
        }
        stderr {
            ike = 1
            knl = 1
        }
    }
}

include /etc/strongswan.d/*.conf
```
So it can be the same for both nodes as it contains info for charon where to log stuff.
Cause I wanted to just check journalctl but forgot that on Alpine there is no systemd, so logging should be done to a file.   
And `ipsec.secrets` contains a super secret PSK:   

```
@r1 @r2 : PSK "somesecretkeyidk"
```

### ipsec.conf

On r1 I wrote this:
```
config setup
    charondebug="ike 2, knl 2, cfg 2"
    uniqueids=no

conn r1-to-r2-policy
    keyexchange=ikev2
    authby=secret
    left=2001:db8:abcd:10::
    leftid=@r1
    leftsubnet=2001:db8:abcd:1111::/64
    right=%any
    rightid=@r2
    rightsubnet=2001:db8:abcd:2222::/64
    ike=aes256-sha256-modp2048
    esp=aes256-sha256
    auto=add
```
I mean kind of wrote, kind of copy-pasted, but i gotta start somewhere.   

`keyexchange=ikev2` means that it will use IKEv2. `authby=secret` means that it will authenticate by a Pre-Shared Key.
`left` is this router's side of the link. I wanted those routers to use `2001:db8:abcd:10::/127` for the point-to-point link. So r1 has `2001:db8:abcd:10::` on `eth1` and you can see that in `topology.clab.yml` in `exec` section.   
`leftid` is just a name that I want to use for r1. Also it is referenced in `ipsec.secrets`.  
`leftsubnet` is the subnet from which the originating traffic is supposed to be encrypted if it is going to `rightsubnet`.   
`right=%any` is used so that the r2 can be behind NAT, so r1 will accept r2's initiation from whatever IP.   

r2's config is similar to r1 but right and left are reversed:
```
config setup
    charondebug="ike 2, knl 2, cfg 2"
    uniqueids=no

conn r2-to-r1-policy
    keyexchange=ikev2
    authby=secret
    left=2001:db8:abcd:10::1
    leftid=@r2
    leftsubnet=2001:db8:abcd:2222::/64
    right=2001:db8:abcd:10::
    rightid=@r1
    rightsubnet=2001:db8:abcd:1111::/64
    ike=aes256-sha256-modp2048
    esp=aes256-sha256
    auto=start
    dpdaction=restart
    closeaction=restart
```

So a bit of explaining now.    
`ike=` specifies the cryptography used for the Internet Key Exchange protocol, so the control plane, whereas `esp=` specifies the cryptography for the data channel, which is handled by Encapsulating Security Payload protocol.  
`aes256-sha256-modp2048` states that AES 256-bit encryption should be used, sha256 is the algorithm for checksums to ensure integrity, and `modp2048` is the Diffie-Hellman key exchange.   
For the IKE Security Association channel, DH algorithm is necessary, but for Child SA, DH KEX algorithm is only necessary if we want to enable Perfect Forward Secrecy.    


As you can see, on r2's side there is `auto=start` but not on r1's side. That because if `right` on r1 is defined as `%any` then r1 does not know where to send the initiation.
R1 can only respond so `auto` is set to `add` on r1.   
