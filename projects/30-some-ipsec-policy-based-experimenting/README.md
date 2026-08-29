# Some experimenting with IPSec IKEv2 and its behaviour 

IPSec is honestly so damn complex and it's hard for me to get a grasp on IKEv2 now. I mean as of now I somewhat get how does IKE_SA_INIT and IKE_AUTH work a bit, but there are so many specific details, and also the MTU can change depending on the cipher and other stuff. 
In wireguard it's 60 or 80 bytes depending on the usage of IPv4 or IPv6 and that is it.  

[This](#intended-failure-at-rekeying-with-pfs) section is interesting, cause it shows a mismatch that can cause a silent traffic loss.    

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

### Intended mismatch 

IKE SA and Child SA Proposals do not allow even a partial mismatch. Out of all the accepted parts from each sides of the tunnel, there must be one that both sides can fully agree on.
If there is something that both sides can't seem to agree on, for example on the ENCR in IKE Proposal, then the initiating side gets a `NO_PROPOSAL_CHOOSEN`.
However the difference between IPSec and Wireguard is that IPSec has two completely different channels, and those channels are authenticated separately.
Basically IKE can go through, but ESP can fail.   
So I wanted to check that in practice.  

On r1 I set `esp=aes256gcm16` instead of `esp=aes256-sha256`, so I deliberately caused a mismatch of the INTEG field. I mean `aes256gcm16` makes it so there is no INTEG field, or it is set to NULL. Cause there is a difference between AEAD, which is Authenticated Encryption with Associated Data and CBC+HMAC here.
`aes256-sha256` means that AES-256-CBC is used for encryption and SHA256 used to compute the checksum. `aes256gcm16` means that AES 256 in Galois-Counter Mode is used with built-in integrity check, cause AES GCM and ChaCha20 both do include integrity in the cipher itself. `16` is the length of the ICV tag in bytes, so 128 bits.   

Then I deployed the lab   

![scrn0](./scrn0.png)   

And basically the tunnel came up so I got kind of confused.

### differences between ipsec.conf and swanctl.conf

The reason for that is actually described in the ipsec man page. Cmd+f and `esp` showed me the section where `esp` behaviour is mentioned. It basically goes like this:
```
esp = <cipher suites>
    [...]
    Defaults to aes128-sha256. The daemon adds its extensive default proposal to this default or the configured value. To restrict it to the configured proposal an exclamation mark (!) can be added at the end.

    Note: As a responder, the daemon defaults to selecting the first configured proposal that's also supported by the peer. This may be changed via strongswan.conf(5) to selecting the first acceptable proposal sent by the peer instead. In order to restrict a responder to only accept specific cipher suites, the strict flag (!, exclamation mark) can be used, e.g: aes256-sha512-modp4096!
```
So this explains everything. Even though i caused an intended mismatch of the INTEG field in Child SA, the daemon added the default cipher suites, so one of them had to be acceptable via both sides.   

In the same man pages, in `ike` section, there is the same thing:
```
ike = <cipher suites>
    [...]
    Defaults to aes128-sha256-modp3072. The daemon adds its extensive default proposal to this default or the configured value. To restrict it to the configured proposal an exclamation mark (!) can be added at the end.

    Note: As a responder the daemon accepts the first supported proposal received from the peer. In order to restrict a responder to only accept specific cipher suites, the strict flag (!, exclamation mark) can be used, e.g: aes256-sha512-modp4096!
```

I even checked the Security Associations for IKE and ESP:    
![scrn1](./scrn1.png)   
So it looks like it used the intended AES-256-CBC with HMAC SHA256 and modp2048 DH group.   
And for the ESP it agreed on AES 256 GCM with 16-byte ICV tag, which is what r1 intended.
So i assume r1 had some kind of priority here, as it wanted `aes256gcm16`, but even though r2 wanted `aes256-sha256`, they agreed on `aes256gcm16`.
Or `aes256gcm16` was just earlier in some kind of a list.   

After adding the exclamation mark on both sides and re-deploying, the ESP channel would not establish, but the IKE channel did:   

![scrn2](./scrn2.png)   

As you can see, there is a selected cipher for IKE but there is no ESP channel visible.   
I checked charon.log on both sides and found the exact point where ESP establishment fails on r1:   

![r1](./r1.png)   

and on r2:   

![r2](./r2.png)   

This line on r2 is crucial `received proposals: ESP:AES_CBC_256/HMAC_SHAZ_256_128/NO_EXT_SEQ`.
I saw that with the IKE proposal, there was no `NO_EXT_SEQ` on the end, and instead there was a long list of different ciphers:   

![scrn3](./scrn3.png)   

So this confirms that ipsec in this specific implementation by default does not really care about the mismatch of `esp=` and `ike=` lines between the endpoints, as it does send all default ENCR and INTEG fields anyway.   
But I couldn't find the exclamation mark in strongswan documentation. Since the ipsec.conf file that I used is the old config, but StrongSwan does now focus on the new config file which is swanctl.conf.   

But there is a section "Default Proposals" in StrongSwan's documentation:
```
If no explicit proposals are configured with the proposals or ah|esp_proposals settings in swanctl.conf, default proposals are used. These proposals can also be added after custom proposals via the default keyword.
```
So it seems like in the new `swanctl.conf` file, the `proposals` and `esp_proposals` sections behave in the opposite ways. 
In `ipsec.conf` the proposals do include default ones but in `swanctl.conf` they do not.   

### intended failure at rekeying with PFS

By default there is no Perfect Forward Secrecy enabled. I mean what decides on whether it is enabled, is the cipher suite used for Child SA.
Typically a DH group is added only for IKE Proposal, but it can be added to Child SA if we want to enable PFS.   

A DH group for ESP Channel is added by adding for example `-ecp384` to `esp=aes256gcm16`, making `esp=aes256gcm16-ecp384`.   
However, the Child SA DH group is not compared at the start of the tunnel. It is first compared only at the end of the soft lifetime of the Child SA, so at rekeying.   

Basically I wanted to see if a BGP connection can survive a rekeying issue caused by a mismatch of the DH groups for the ESP channel.
In theory, the ESP establishment should fail only at the keys soft lifetime end, since a mismatch of DH groups for Child SA, should not be noticed neither at IKE_SA_INIT nor at IKE_AUTH.
And BGP session should survive and not drop, since the hold timer is usually longer than the estimated interruption.   

But before that I had to set the timers low so I wouldn't have to wait long to see the effect and issues. 
However I thought that at this point it's better to transfer the configs from ipsec.conf to the newer syntax in swanctl.conf. Also swanctl.conf syntax is more readable.
So this is how r1.swanctl.conf looks like:   
```
connections {
    r1-to-r2-policy {
        version      = 2
        local_addrs  = 2001:db8:abcd:10::
        remote_addrs = %any
        proposals    = aes256-sha256-modp2048
        rekey_time   = 60s
        local {
            auth = psk
            id   = r1
        }
        remote {
            auth = psk
            id   = r2
        }
        children {
            r1-to-r2-policy {
                local_ts  = 2001:db8:abcd:1111::/64
                remote_ts = 2001:db8:abcd:2222::/64
                esp_proposals = aes256gcm16
                rekey_time = 15s
                life_time  = 30s
                dpd_action   = restart
                close_action = restart
                start_action = none
            }
        }
    }
}
include swanctl.secrets
```
A bit of explaining now. The main difference between ipsec.conf and swanctl.conf is like the difference between EOS' startup.cfg and BIRD's bird.conf.
swanctl.conf uses a format with blocks instead of indentation.    
`version = 2` is equal to `keyexchange=ikev2`, `local_addrs` is the same as `left` and `remote_addrs` is equal to `right`, `leftid=@r1` is now `local { id = r1 }`, `ike` is now `proposals` and `esp` is now `esp_proposals`.   
The rest is pretty self explanatory. Here I use the same trick as before with `right=%any` but now with `remote_addrs = %any`, so that r2 can be behind NAT, though it is not behind NAT right now.   

Also by default the secrets are in the `secrets { }` block but there is a way to place them in a separate file, by adding `include swanctl.secrets` in `swanctl.conf`.   

The contents of `swanctl.secrets` look like this:   
```
secrets {
    ike-r1-r2 {
        id-1   = r1
        id-2   = r2
        secret = "somesupersupersecretkey"
    }
}
```
So in `topology.clab.yml` i had to replace the `r*.ipsec.conf` bind with:   
```
      binds:
        - r2.swanctl.conf:/etc/swanctl/swanctl.conf
        - swanctl.secrets:/etc/swanctl/swanctl.secrets
```
And in exec I removed `ipsec restart` and instead added those lines:
```
      exec:
        - ipsec start
        - sleep 2
        - swanctl --load-all
```
And also `swanctl --load-all` is kind of more verbose than `ipsec restart` when launching it with `clab deploy`.
`ipsec restart` didn't really output anything into `stdout` but `swanctl --load-all` does talk a bit:   

![scrn4](./scrn4.png)   

