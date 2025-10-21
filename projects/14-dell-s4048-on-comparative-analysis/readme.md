# Analysis and justification for selecting the Dell EMC S4048-ON switch for my lab

**Table of contents**        
1. [Abstract](#abstract)
2. [Goals and requirements](#goals-and-requiremets)
3. [Analyze of platforms](#platform-analysis)

> NOS - Network Operating System such as Ciscos IOS    

# Abstract
So basically this will be a shorter documentation cause there won't be much going on here, apart from me just explaining why I choose the Dell EMC S4048-ON ToR switch for my lab instead of some other models.    

I kind of want to try writing docs in more concise or formal way so this won't be a flow of thoughts like in, for example, [School network analysis](../13-school-network/readme.md).   

I will shortly compare it to Juniper QFX5100 and Ubiquiti Campus 24 PoE, though I never actually even considered the Ubiquiti one for my lab, but since it is in fact a very popular model, I want to use it just as a comparison for the two other switches.   

# Goals and requirements


So I would like to first state what I was actually looking for in a switch.   

for that reason, I want to clarify what is the actual goal of my whole lab.   
As you may have already seen, there is close to no services running in my lab. 
There is no Plex, no Jellyfin, no kind of any game server, not even a NAS.
That is because I didn't start this lab to free myself from cloud services, for example by running Immich instead of relyingon iCloud.   
I'm building this lab to learn actual datacenter networking technologies rather than to just use it as a self-hosted setup.    

And this is a very important thing which I think strongly divides the two sides of labbing.    

I mean running your own Netflix, Google Photos etc. is of course cool, but there is no way that it's possible to learn advanced networking technologies used in real datacenters from it.   

And I just never felt the urge to free myself of Apple services.
Mainly because I love the integrity that Apple devices provide when using their cloud services.    

So in summary, because of the goal of my lab, I was looking for something very different, for different reasons, than self-hosted labs.   

The first thing that made me even consider buying something new for my lab was that I wanted to get into the real data center technologies, which simply are not fully supported, or not supported at all on my MikroTik devies.    

For example, ECMP for BGP or stable implementation of EVPN-VXLAN.   
The second thing, is in fact supposedly supported on RouterOS, but with one very important note.
It's available currently only on v7.20beta.   

I could theoretically update to the beta to make it available for me, but actually I have absolutely no reason to do that.    

Don't get me wrong, MikroTik devices are great, but for example, long-standing bugs with DHCP on stable versions, or glitching conntrack makes them just nowhere near suitable for data center environments.    

But I won't get more into MikroTiks since this section is supposed to be just a overview of the requirements.

And besides, even if those technologies were well supported on ROS, there is still the fact that ROS is a monolithic Network Operating System.   
Sure, there is supposedly a light-weighted Linux kernel below, but the services do not run as actual Linux daemons, and the CLI is actually a wrapper for the API, not the actuall Shell.

So as you may suspect, it does not give any bare-metal-like access to the device, like bash does, and also this is a big difference in the context of Python/Ansible automatization and debugging.    

I realize that for many people this may seem like a whim, but in what other way, can a person learn NOS' architecture, other than by owning a device with a appropriate NOS?

I mean like honestly I don't think that it's possible to even remotely appreciate how insane it is to use a full carrier-grade modular Linux-based system in comparison to monolithic systems.   
And I still cannot comprehend how powerful real carrier-grade systems are, even though now I own a device with one.    

It's just that the ability to reset every single service separately without even a warm restart is first of all amazing, but secondly it's an absolute neccesity in data centers.

So I think this is enough for now to justify the need for an advanced network operating system.    

Now another thing is hardware support for advanced protocols.   

As you may, or may not know, I absolutely love getting very deep into the architecture of networking devices and network operating systems.
I read tons of white papers and documentations about how certain switching chips are built, what processing engines does the traffic go through inside of them etc.  

For example let's very shortly look into the MikroTik CRS326 switch chip. 
It uses a Marvell Prestera 98DX3236 chip with a couple of L3 hardware offload abilities.
I would like to point your attention to the term "offloading".    
I won't get into detail about that for now, since I want to leave this topic for one of my next docs, but basically offloading some of the L3 functionality from the CPU onto the switch chip, is far from the switch chip being made from scratch to handle L3 functionality.   

I would like to also state here a important thing, which is the fact that the maximum number of IPv4/IPv6 routes in a switch, is strictyl dependent on how big the CAM/TCAM memory blocks are.  

> [!IMPORTANT]    
> As I already said, I don't want to write a lot here about the TCAM memory, because I will write an entire other documentation about TCAM memory blocks and switching engines, specifically in the StrataXGS series ASICs from Broadcom, so for now I'm getting back to the actual topic of the document.  

Basically, I wanted something that could perform full L3 functionality, in the switch chip.   
For example, can the CRS326 perform L3 Lookup? 
Sure it can, but only for a maximum of ~36 thousand IPv4 routes, and additionaly, mostly only with static routing.   

And can it perform VXLAN encapsulation/decapsulation? 
Absolutely no, and that is because there is no VXLAN encapsulation/decapsulation engine inside that switch chip.    

That is why I wanted something with a stronger switch chip (astronomically more powerful actually as you will see below).

So I think this concludes a couple of first requirements for the device:     
*   Full carrier-grade modular Network Operating System     
*   Powerful switch chip with L3, VXLAN in-sillicon support.     


