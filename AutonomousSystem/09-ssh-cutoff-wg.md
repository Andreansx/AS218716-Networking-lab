## Just wanted to note how I cut my ssh off by forgetting one option in wireguard config

Basically I was setting up wg1 tunnel, you can read about it [here](./07-ips-interfaces.md).    

I would like to automate wg1-3 tunnels and rekeying with Ansible, but I will do that in the future.
For now I got into the configuration manually.   

First I wrote the wg1.conf for `edge01.zrh.andreansx.net`:   

```
[Interface]
Privatekey=...
Address=2a06:9801:1514:31::2/64
ListenPort=49582
table=off

[Peer]
Publickey=...
AllowedIPs=::/0,0.0.0.0/0
endpoint=45.154.99.209:45922
PersistentKeepalive=25
```
> [!NOTE]
> I do know that it is not necessary to set up an endpoint on this side, since `edge01.dus.andreansx.net` is also initiating the connection, but it cannot hurt.   

I placed the file in `/etc/wireguard/wg1.conf` ran `sudo wg-quick up wg1`.   
Then I wrote the config for `edge01.dus.andreansx.net`:
```
[Interface]
PrivateKey=...
address=2a06:9801:1514:31::3/64
ListenPort=45922

[Peer]
Publickey=...
endpoint=185.44.82.168:49582
persistentkeepalive=25
AllowedIPs=::/0,0.0.0.0/0
```
And again, I placed the file in `/etc/wireguard/wg1.conf` and proceeded to run `sudo wg-quick up wg1`, which resulted in my ssh connection getting cut off.   

I had to login to Servperso's proxmox panel and use noVNC to log into the server and disable wg1.   

First thing that caught my eye was the difference in outputs of two `wg-quick up` commands.
The first one (on `edge01.zrh.andreansx.net`), returned this:   
```
aether@edge01.zrh.andreansx.net:~$ sudo wg-quick up wg1
[#] ip link add wg1 type wireguard
[#] wg setconf wg1 /dev/fd/63
[#] ip -6 address add 2a06:9801:1514:31::2/64 dev wg1
[#] ip link set mtu 1420 up dev wg1
```
But the second one (on `edge01.dus.andreansx.net`) returned different output:
```
aether@edge01.dus.andreansx.net:~$ sudo wg-quick up wg1
[#] ip link add wg1 type wireguard
[#] wg setconf wg1 /dev/fd/63
[#] ip -6 address add 2a06:9801:1514:31::3/64 dev wg1
[#] ip link set mtu 1420 up dev wg1
[#] wg set wg1 fwmark 51820
[#] ip -6 route add ::/0 dev wg1 table 51820
[#] ip -6 rule add not fwmark 51820 table 51820
Read from remote host 2a06:9801:1514:2::3: Operation timed out
Connection to 2a06:9801:1514:2::3 closed.
client_loop: send disconnect: Broken pipe
```
And at this point the ssh connection was cut off.   

So i noticed the difference between those outputs and started looking at the configs to see what varied between them.
And I didn't have to look long to notice I put `table=off` in the first one, but did not in the second config.
So this is pretty straightforward, wg-quick does by default install routes to the networks stated in `AllowedIPs`, into the kernel. 
As I did in fact add `::/0,0.0.0.0/0` into `AllowedIPs`, forgetting to state `table=off`, made `wg-quick` install a dev route to `::/0` and `0.0.0.0/0` into the kernel in a different table (table 51820), and it started forwarding everything to wg1.

With IPv6 the situation is as follows. The route to `wg0` is shorter than the default in `main` table, so it survives.   
With IPv4 it is a bit different. The external IPv4 endpoint for the tunnel is reachable only via the default route anyway. Packets from `wg0` do not have `fwmark 51820` so they do go into `table 51820`, and next into `wg1` 

So first thing to fix that, is to make sure that `table=off` is stated in the wg config file for the tunnel.   

However that is not the only fix for this particular issue.    

The endpoints for wg0, which is the management tunnel, are on IPv4, so I changed AllowedIPs to:
```
AllowedIPs=::/0
```
and afterwards I ran the tunnel, which did not result in my ssh connection getting cut off:
```
aether@edge01.dus.andreansx.net:~$ sudo wg-quick up wg1
[#] ip link add wg1 type wireguard
[#] wg setconf wg1 /dev/fd/63
[#] ip -6 address add 2a06:9801:1514:31::3/64 dev wg1
[#] ip link set mtu 1420 up dev wg1
[#] wg set wg1 fwmark 51820
[#] ip -6 route add ::/0 dev wg1 table 51820
[#] ip -6 rule add not fwmark 51820 table 51820
[#] ip -6 rule add table main suppress_prefixlength 0
[#] nft -f /dev/fd/63
```
However, that is not a fix actually, even though there does not seem to be a problem right now.
This actually added a default route, for IPv6, pointing to `wg1`. A simple check does show that in fact, IPv6 got somewhat broken:
```
aether@edge01.dus.andreansx.net:~$ ping -6 google.com
PING google.com (2a00:1450:4001:c1f::71) 56 data bytes
^C
--- google.com ping statistics ---
7 packets transmitted, 0 received, 100% packet loss, time 6138ms

aether@edge01.dus.andreansx.net:~$ sudo wg-quick down wg1
[#] ip -6 rule delete table 51820
[#] ip -6 rule delete table main suppress_prefixlength 0
[#] ip link delete dev wg1
[#] nft -f /dev/fd/63
aether@edge01.dus.andreansx.net:~$ ping -6 google.com
PING google.com (2a00:1450:4001:c1f::71) 56 data bytes
64 bytes from bz-in-f113.1e100.net (2a00:1450:4001:c1f::71): icmp_seq=1 ttl=116 time=4.59 ms
64 bytes from bz-in-f113.1e100.net (2a00:1450:4001:c1f::71): icmp_seq=2 ttl=116 time=5.99 ms
64 bytes from bz-in-f113.1e100.net (2a00:1450:4001:c1f::71): icmp_seq=3 ttl=116 time=4.55 ms
^C
--- google.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2001ms
rtt min/avg/max/mdev = 4.547/5.044/5.992/0.670 ms
aether@edge01.dus.andreansx.net:~$
```
And with `ip route get`, I can see that in fact, a route to google's IPv6 is pointed to `wg1`:   
```
aether@edge01.dus.andreansx.net:~$ ip route get 2a00:1450:4001:c13::65
2a00:1450:4001:c13::65 from :: dev wg1 table 51820 src 2a06:9801:1514:31::3 metric 1024 pref medium
```

So after all, I should just have `table=off` in both configs.
> [!IMPORTANT]
> Keep in mind, that restricting `AllowedIPs` is not a valid fix. `AllowedIPs` must be set to `::/0`, since traffic in and out of my AS, will sometimes pass through `wg1`, and with `AllowedIPs` restricted, the traffic would get silently dropped at one of the ends of `wg1`. iBGP will work also on top of `wg1`, and it will decide the routes for specific destinations, so there is no need for wg-quick to install the routes in the kernel.   

However, I will in fact leave only `::/0` in `AllowedIPs`, since no IPv4 traffic will pass through `wg1` anyway.

> [!NOTE]
> I did use `/64` addresses in the configs instead of `/128`, as stated in [ips-interfaces](./07-ips-interfaces.md). That is because with `/128` addresses, there is no way to ping each other. I mean, `edge01.zrh.andreansx.net` cannot ping `2a06:9801:1514:31::3` (`edge01.dus.andreansx.net`'s side). Maybe this should work, but for me it does not work even with `-I wg1`:    
> ```
> aether@edge01.dus.andreansx.net:~$ ping -I wg1 2a06:9801:1514:31::2
> PING 2a06:9801:1514:31::2 (2a06:9801:1514:31::2) from 2a06:9801:1514:31::3 wg1: 56 data bytes
> ^C
> --- 2a06:9801:1514:31::2 ping statistics ---
> 2 packets transmitted, 0 received, 100% packet loss, time 1021ms
> ```   
> with `/128` address, `wg-quick` does not install a route to the subnet, so the whole `/64` seems unreachable from each side.   
