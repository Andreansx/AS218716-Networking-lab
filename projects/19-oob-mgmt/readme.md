# Out-of-Band Management setup 

Kind of took a bit of a break from networking for a while after I passed CCNA but now I would like to implement real OOB Management in my network.   

~~To complete that I'm gonna use the old Brocade FLS648 switch, Open vSwitch in Proxmox and VRFs to separate the Management interfaces in my devices.~~  

Actually I have a better idea which removes the need for the FLS648. 
I'll just bridge all `eno1`-`eno4` 1GbE RJ45 ports in the Dell PowerEdge R710 to a Linux Bridge (or OVS) and use it as a switch for the OOB Mgmt network.  
I will be able to plug connect the Management interfaces directly to interfaces in the R710 server and it will act as a switch for the oob management network.

Until now, the Management setup was kind of weird and for sure unprofessional because each MikroTik router had it's own small Management network.

For example the CCR2004 had `ether1` interface in the `10.1.1.0/30` network and CRS326 had `ether1` in the `10.1.1.4/30` network.  
That kind of worked but this is nowhere near real Out-of-Band Management which is implemented in Data Centers so I'm gonna change that.  

I put together a diagram which gives an overview on how I want the OOB Management to be.  

![oob.png](./oob.png)   

The only issue that i could point out for now is that there's now a single point of failure being the availability of the R710.   
If Proxmox doesn't come up online then the OOB Mgmt doesn't work at all. 
Also, the R710 does not have a hardware acceleration for L2 switching which in short means that it doesn't work well as a switch because every frame needs to go through the CPU.   

I don't think that it's a big deal for the Management network but if I used a dedicated switch like the FLS648, there would be absolutely no problem with switching at line-speed in the management network.   

The thing is that I can actually leave the configuration which bridges all RJ45 1GbE ports in the R710 NIC and if I want to change something then I can just plug the FLS648 into one of those ports and then plug the rest of the management interfaces to the FLS648 as it has the most basic configuration possible.   



