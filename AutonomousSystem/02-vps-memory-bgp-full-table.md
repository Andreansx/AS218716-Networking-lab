# About why 2GBs on VPSes because of LocIX and FogIXP  

At first I was thinking about ordering an iFog Switzerland Ryzen VPS with 1vCore, 1GB RAM, 25GB NVMe SSD for 6 CHF a month.   
However having only a single gigabyte of memory does poses a risk of OOM, since I intend to have a full BGP IPv6 table along with bird-lg-go and nginx on both PoPs.   
I won't install a full IPv4 BGP table, since I have nothing to announce and full IPv4 plus IPv6 tables would require too much RAM.   
So the decision is that BIRD will install the full IPv6 BGP table, which is around 250k prefixes long now and will fill the Looking Glass, and for IPv4 I will only install a default route. 
Though I will have not to include `import keep filtered on;` in BIRD, since that would make BGP take twice as much RAM.    

### FogIXP

When I wanted to order iFog 1GB VPS I saw that under "BGP Session CHF 0,00" option, there was another one, "FogIXP port CHF 0,00". 
I went to read a bit about FogIXP [here](https://fogixp.org/our-ixps/europe).
And I mean just after some reading I guess everyone can say that it would be hard to not add this to my order.
Having my PoP connected to a real IXP makes my Looking Glass somewhat interesting, since without an IXP, my LG would just show always two routes beginning with either iFog or Servperso.   
I mean, to most destinations, my LG will still show only a route via either iFog or Servperso, BUT some destinations, which are really mostly Autonomous Systems like the one I am creating, Autonomous Systems owned by enthusiasts, small businesses etc. will be reachable via the IXP.   
However the biggest value of being connected to a real small, open-peering IXP in my case is not making the LG more interesting, but rather the fact, that FogIXP has Route Servers with real BGP communities.
