# About why 2GBs on VPSes because of LocIX and FogIXP  

At first I was thinking about ordering an iFog Switzerland Ryzen VPS with 1vCore, 1GB RAM, 25GB NVMe SSD for 6 CHF a month.   
However having only a single gigabyte of memory does poses a risk of OOM, since I intend to have a full BGP IPv6 table along with bird-lg-go and nginx on both PoPs.   
I won't install a full IPv4 BGP table, since I have nothing to announce and full IPv4 plus IPv6 tables would require too much RAM.   
So the decision is that BIRD will install the full IPv6 BGP table, which is around 220k prefixes long now and will fill the Looking Glass, and for IPv4 I will only install a default route. 
Though I will have not to include `import keep filtered on;` in BIRD, since that would make BGP take twice as much RAM. (Or so I thought, read below)    

### FogIXP

When I wanted to order iFog 1GB VPS I saw that under "BGP Session CHF 0,00" option, there was another one, "FogIXP port CHF 0,00". 
I went to read a bit about FogIXP [here](https://fogixp.org/our-ixps/europe).
And I mean just after some reading I guess everyone can say that it would be hard to not add this to my order.
Having my PoP connected to a real IXP makes my Looking Glass somewhat interesting, since without an IXP, my LG would just show always two routes beginning with either iFog or Servperso.   
I mean, to most destinations, my LG will still show only a route via either iFog or Servperso, BUT some destinations, which are really mostly Autonomous Systems like the one I am creating, Autonomous Systems owned by enthusiasts, small businesses etc. will be reachable via the IXP.   
However the biggest value of being connected to a real small, open-peering IXP in my case is not making the LG more interesting, but rather the fact, that FogIXP has Route Servers with real BGP communities.   
So I could work with real pre-pend 1x,2x,3x, no-announce to a real peer etc.   

Sessions to the RS also need some memory. There are three Route Servers and more than 300 connected networks in FogIXP in Europe total so I guess there can be more than 100k prefixes there.
Good thing is that my iFog VPS is in the same physical location as one of the core PoPs of the Zurich part of the IXP.   

So as I said, neither Google or Cloudflare or Akamai is connected to that IXP, since that is a smaller, oriented for enthusiasts and small companies IX, but there is real value in being connected to FogIXP, which is being able to work with real BGP communities, and that is not achievable in containerlab in orbstack.   

So in the end I decided on and ordered the VPS for 10CHF a month, the one with 2 vCPUs, 2GB of RAM and 50GB NVMe.
It will cost in total 120CHF a year rather than 72CHF so a bit more but it will allow me to sit comfortably on that FogIXP and not risk a OOM process kill at every BIRD reconfiguration.   

### LocIX Dusseldorf

This one is about Servperso VPS. I ordered a VPS from them before ordering one from iFog. I got the one for 28,66 EUR including 23% VAT on quarterly billing. It's the `Basic` one with 2 vCores, 2GB RAM, 15GB SSD and 1 IPv4 plus one IPv6. Though it has only 500Mbps link speed, but that is not really a problem, although the iFog VPS has up to 10Gbps with 8TB monthly traffic.   

At the time I ordered it, I didn't really look into the option for free access to LocIX DUS and NL and BGP.Exchange, but now after reading a bit more into FogIXP, LocIX Dusseldorf seems like a very nice thing.   
It is smaller than FogIXP, but again, this is mostly valuable in terms of working with BGP communities and I mean, it is definitely better than just being connected to a single AS.  

Basically having an IXP port does not mean that the Looking Glass will magically be amazing.   

So whether I will be connected to LocIX DUS depends on how does connecting work, since with FogIXP it is simple, cause FogIXP is owned by the same company as my VPS, so connecting is trivial.
But LocIX is a separate organisation, it is not owned by Servperso Systems, so I assume that I will have to register with LocIX myself, but Servperso will provide the L2 connection.
I sent a ticket to Servperso about that and also asked if the connection is delivered via a separate interface or via a tagged VLAN on the existing interface. [Check below](#servperso-response)   
By the way, Serperso exposes the Proxmox panel for accessing the VPS, so I have more insight into the VM and I also can install whatever OS I want, since they have a lot of ISOs on the mounted ISO Storage.   

So the total costs of the VPSes come out to 120CHF + 114,64EUR a year, but having 2GBs of RAM will provide more comfort. I mean not really a room for comfort, since 2GBs is more kind of the minimal reasonable amount for a full IPv6 table plus tens of thousands of prefixes from the IXP.    

###### servperso response
Also, in a recent response to a ticket from Servperso, they said:   
> "Every ixp is delivered as a separate interface. \[...\]   
> For locix, we do the registration on our side after you got an asn and a peeringdb account."    

So LocIX is pretty straightforward and I am glad that Servperso does handle the registration. I will just fill out the blanks in my PeeringDB profile after I get the ASN from iFog.   

