# Why not Vultr or BGPTunnel.com and Oracle Always-Free VPS 

Oracle offers a VPS that is completely free, and it includes 200GBs of boot volume and 1 oCPU in the VM.Standard.E2.1.Micro Shape with 1GB of RAM.   

[BGPTunnel.com](https://bgptunnel.com) is iFog GmbH's free service for BGP transit and it uses GRE.
I was thinking about setting up a OCI VPS, and then just tunneling my IPv6 via BGPTunnel.com to it, and then again tunneling it through Wireguard to my MikroTik CCR2004 at home.   

So, the first thing is that Oracle Always-Free VPSes have a tendency to get randomly removed by the Always-Free OCI Reaper. There is no SLA etc.   
Another thing is that BGPTunnel.com is not eligible to be one of the two upstreams needed for RIPE ASN assignment, it does not fit the requirements in the routing policy.   
And Oracle itself does not establish a BGP session with a client.   

I was also thinking about Vultr, which I later considered not eligible for my need, cause they are an hourly cloud provider but RIPE requires two upstreams which cannot be hourly cloud providers (or so I thought).
Turns out that this is only an iFog's requirement and not a RIPE requirement in general, for example, Lagrange Cloud, after I asked them, confirmed that there is no restrictions on using hourly cloud providers for people in the RIPE NCC region.   

Part of the response from Lagrange Cloud, that I received:   

> "There are no restrictions on using hourly providers as upstream. RIPE will accept any valid ASN, although may request evidence if you list a noteworthy partner such as Cloudflare or Google. The only "restriction" on hourly providers is for requests from customers outside the RIPE region who are requesting a RIPE ASN, as they must provide an invoice for a VPS or similar within the RIPE region. Most hourly providers do not issue invoices in a format acceptable by RIPE due to how their services operate. You are in-region so do not have to provide an invoice."   

So after all, I could use Vultr, but only if my sponsoring LIR would be other than iFog, as stated on iFog's website:   
> Notes:   
> IMPORTANT regarding AS-Number registration:   
> -We require a copy of your Passport and/or Company Certificate, two Upstream Carrier with AS-Number and eMail you plan to use for the RIPE NCC.   
> -Documents such as Company Certificate or Certificate of good standing cant be older than 3 months.   
> -Upstreams MUST be in the RIPE NCC Service region (eg. Europe) and CANNOT be a hourly cloud provider. If you are outside the region, you will need to provide Invoices of your upstreams within the region.   


