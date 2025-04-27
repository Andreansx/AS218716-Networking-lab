## Hey there
## Happy to see you visiting this repository dediacted to general documentation of my networking lab.

![Dell](https://img.shields.io/badge/dell-%230012b3?style=for-the-badge&logo=dell)
![Proxmox](https://img.shields.io/badge/proxmox-proxmox?style=for-the-badge&logo=proxmox&logoColor=%23E57000&labelColor=%232b2a33&color=%232b2a33)
![Cloudflare](https://img.shields.io/badge/Cloudflare-F38020?style=for-the-badge&logo=Cloudflare&logoColor=white)
![MikroTik](https://img.shields.io/badge/MikroTik-%23363636?style=for-the-badge&logo=Mikrotik)

## Hardware overview
> My networking lab consists of servers, routers, switches and other devices.  
> Below you can see a brief overview of them
## Servers

### Dell PowerEdge R710  

This is a pretty old server. It is loud, power-hungry and not really powerful.  
However, for now it does what it is meant to do.  
Current specification:
- Double Intel Xeon X5670. 12 cores and 24 threads in total at around 2.90 GHz
- 128 GB of DDR3 ECC RDIMM memory. Samsung and Skhynix
- Double 870W PSU
- 2x 10GbE RJ45 Network card but it isn't currently used for anything  
Drives:  
    - Dell certified 146 GB HDD SAS 15K ( Proxmox )
    - Dell certified 600 GB HDD SAS 10K
    - HGST 900 GB HDD SAS 10K  

- 4x 1GbE RJ45 NDA

As you can easily see above, it is not a cutting edge configuration. I am thinking about buying a used **Dell PowerEdge R740 server**. This would allow me to run more virtual machines at once. Along with 2x SFP+ ports, this would be a great improvement and a addition to my lab.  
However, it is not easy to get that money but this is my aim for now apart from learning networking.  

### Dell PowerEdge R610

I don't really have anything to say about this device. It's worth more on the junkyard than in the terms of computing power. 

- Double Xeon E5520 
- 36 GB of DDR3 ECC RDIMM memory. Most likely I will take it out and save it for something else  
- 2x 717W PSU  

Nothing more than that. It basically just collects dust. I will probably give it to someone for free. Until that, it will sit at the bottom of the server rack.

## Routers

### ISP Router

GPON ONT + Router provided by my ISP, **VICTOR**.
- 4x 1GbE RJ45
- 1x SC/APC fiber connector.  

I enjoy having internet access from this ISP. However one thing that I would like to have, is access to the router admin panel. Since I don't have any access to that, I can't even change the Wi-Fi password, which is actually a security risk. Otherwise than that, the service is pretty good and the ping is low, no more than **6-7ms**.

### MikroTik CCR2004

The explicit model of this router is **CCR2004-1G-12S+2XS**.  
It's a very powerful router with a lot of capabilities.

- 1x GbE RJ45 Management port
- 12x SFP+ ports
- 2x SFP28 ports

