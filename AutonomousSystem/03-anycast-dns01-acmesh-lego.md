# Here I wanted to write about why I need to use DNS-01 instead of HTTP-01 for the Let's Encrypt SSL and why lego or acme.sh 

The main issue with using it with my domain, which will be anycasted, is that because of anycast itself, the response may arrive at different PoP than the one it was suppposed to arrive at.

Also, using wildcards like `*.andreansx.net` is not possible with HTTP-01.   

With HTTP-01 it works like this. first the acme client requests a certificate from Let's Encrypt, LE tells it to place a file with the token in for example `http://lg.andreansx.net/.well-known/acme-challenge/<token>` and then the client places the file there and after that LE sends a request on port 80 to the PoP and checks if the file exists and if it has the right token, and then LE acknowledges that I do control that server so it signs the certificate.   

So ultimately I have a domain `lg.andreansx.net` with AAAA record pointing to `myprefix:a::1` and that prefix is originated from two PoPs, one in Zurich and one in Dusseldorf. 
So when someone sends a request to `:a::1`, they do not really know to which PoP it will go. 
And another thing on top of that is the fact that LE does something called Multi-Perspective Validation, which basically means that LE will sends request to my domain from different points in the world, that is used to counter a regional BGP hijack.  

And DNS-01 does fix that in a really elegant way, by completely not connecting to my server. 
It just needs my acme client to place a TXT record in the DNS server, with a name `_acme-challenge.lg.andreansx.net` with value of `token` then my client places the record there through Cloudflare API. 
And then LE asks not my server but only the DNS server, about the value of that record, checks if it is right, and then if it is, it signs the cert.   

So HTTP-01 more proves that I have the server but DNS-01 proves that I own the domain.   

And that is super convenient for anycast and also since the acme client does not have to be reachable from the internet, then my acme client can be for example on my thinkpad behind CGNAT, and that would offload the PoPs.   
Also it is better to have a single point which revalidates the certificate, so my thinkpad does fit that.  

The thinkpad will every 60 days request for a new sign on the certificate from LE, it will place the appropriate record through Cloudflare API, and that is it. 
And it is safer than having acme.sh or lego on the PoPs themselves, cause the PoPs are in fact more exposed than my thinkpad, so having Cloudflare API keys stored there poses a bit more of a risk than having the key locally.   

And I will not use certbot, cause both VPSes do have 2GBs of RAM and both will be connected to Route Servers in IXPs, so I figured it is better to have something lighter than certbot. I think I will go with lego.   

And another thing is that I have Cloudflare Proxy turned off and it will need to be turned off for A and AAAA records, since having it enabled would take out all the fun from having my website anycasted.    
