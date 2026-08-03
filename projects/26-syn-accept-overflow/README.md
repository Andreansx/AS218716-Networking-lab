# I wanted to do some projects more oriented towards Akamai, so it's a good thing to get more familiar with edge linux servers, cause that's one of the things that Akamai uses, cause they provide CDNs after all.   

## So here I wanted to do a simulation of spontaneus RSTs when connecting to a server, caused by the overflow of accept/SYN queues. That is something that could happen with CDNs as there are lot's of small requests etc.

I'll run just two linux containers in an OrbStack ARM64 VM on my Mac. One with a super simple python http server and the other one with `wrk` which will generate the traffic, and enough of it to overflow the two queues on the listening socket.
