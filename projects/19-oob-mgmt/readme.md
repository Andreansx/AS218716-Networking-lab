# Out-of-Band Management setup 

Kind of took a bit of a break from networking for a while after I passed CCNA but now I would like to implement real OOB Management in my network.   

To complete that I'm gonna use the old Brocade FLS648 switch, Open vSwitch in Proxmox and VRFs to separate the Management interfaces in my devices.  

Until now, the Management setup was kind of weird and for sure unprofessional because each MikroTik router had it's own small Management network.

For example the CCR2004 had `ether1` interface in the `10.1.1.0/30` network and CRS326 had `ether1` in the `10.1.1.4/30` network.  
That kind of worked but this is nowhere near real Out-of-Band Management which is implemented in Data Centers so I'm gonna change that.  
