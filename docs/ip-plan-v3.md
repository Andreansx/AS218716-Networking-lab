# Yet another addressation plan

10.100.0.0/16 block is a bit too long to type in to be honest.  
What I planned to use was a 10.1.0.0/16 block for addressation.  

However I won't place all management interfaces in the same network, because when, for example, Core switch (Which handles inter-VLAN routing) has a management interface on 10.100.10.2/28, and the Core Router has a management interface with 10.100.10.1 IP address, then this will become the highest priority route for all VLAN traffic accessing outside world. This of course is not a safe practise, VLANs should access internet through a inter-router link.   

But since, the management network is the highest priority route for pretty much everything, then the inter-router link becomes pointless.  

From what I read about management interfaces addressation in data centers, there shouldn't really be any big network where every management interface is placed in, because it's not good when untrusted traffic goes through a highly sensitive network. In data centers, from what I know, they use OOB Management, but I can't really do that in my lab for now.
