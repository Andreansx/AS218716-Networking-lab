## I wanted to do write here a kind of a post-mortem document, cause I had an issue with Wireguard, SSH and nftables and wanted to write that down before I forget how it went.

So basically, I wanted to use `2a06:9801:1514:2:/64` for management wireguard links. 
`edge01.dus.andreansx.net` was supposed to be `2a06:9801:1514:2::3` and `edge01.zrh.andreansx.net` was supposed to be `2a06:9801:1514:2::2`.
However, on the [diagram](../../media/ownassimplified.png), I had ::3 for zrh and ::2 for dus. 
So generally I wanted to change that both on the diagram and on wireguard links themselves.   

Keep in mind that Dusseldorf VPS has nftables and Zurich VPS does not.   

So I first edited the `/etc/wireguard/wg0.conf` on Zurich VPS (changed `Address` in `[Interface]`, and `AllowedIPs` in `[Peer]`), then wrote `change.sh`:
```sh
#!/bin/bash
wg-quick down wg0 
wg-quick up /etc/wiregurd/wg0.conf
```
and ran it in byobu window as root. Then I changed the AllowedIPs in the file on my MacBook [here](../../MacBookProM2Max/wg-to-edge01.zrh.andreansx.net.conf.empty)   

And after resetting the wireguard link in Wireguard app on my Mac, the handshake went through and I could log in via SSH on the IPv6 Wireguard link.   

However with the Dusseldorf VPS there was a problem. I did the same thing with the `change.sh` file after editing the `/etc/wireguard/wg0.conf`, but after changing `AllowedIPs` on my side, the SSH connection would just hang.   
What is interesting is that ping went through. The handshake was successful but SSH could not connect. I logged in via Proxmox VE noVNC console to check `nft list ruleset`, and I saw that there were no hardcoded IPs in nftables config.   

After doing `cat /etc/nftables.conf` and `nft list ruleset` I noticed a difference between those two outputs.   
There was a line in `/etc/nftables.conf` that was `iif "wg0" tcp dport 22 accept`, but in `nft list ruleset` output that line was `iif 4 tcp dport 22 accept`.   

However, I was looking at `ip a` and noticed that the line with `wg0` went like this `6: wg0: <POINTTOPOINT,NOARP,UP,LOWER_UP> mtu 1420 ...`. 
So I figured that the indexes of the interfaces were different.   

I ran `wg-quick down wg0` and `wg-quick up wg0` again, but that did not fix the issue, however I saw that the index of `wg0` in `ip a` changed from 6 to 7. So it must be that the indexes change at each up/down of a wireguard interface.   

I then ran `systemctl restart nftables`, which didn't help, but then ran `systemctl reload nftables` and then the SSH connection did went through.   

However, that would mean that the problem would persist and would come up at every `wg-quick` reset. 
So I saw that I should change `iif "wg0"` to `iifname "wg0"`, because `iif` uses the interface index at the point of loading the nft ruleset from file, but `iifname` does supposedly check the name at every point, not the index.   
