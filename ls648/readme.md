<div align="center">
<h1>Brocade FastIron LS648-STK</h1>
<h3>Specifications</h3>
</div>
<div align="left">
<ul>
    <li>Ports: 48 x 10/100/1000 Mbps RJ45 ports</li>
    <li>Combo ports: 4 x 10/100/1000 Mbps SFP ports</li>
    <li>Switching Capacity: 176 Gbps</li>
    <li>Forwarding Rate: 130 Mpps</li>
    <li>Power Consumption: 150W</li>
    <li>Dimensions: 1U rack mountable</li>
</ul>
</div>
<div align="center">
<h3>Firmware Issue</h3>

# Below is a copy of the issue with the firmware that I documented in my deprecated repo. 
# I will try to rewrite it here if I find any mistakes.
</div>

### How it started
Some time ago, I wanted to do some inter-vlan routing on this switch since I found that it *is* capable of that. </br>
I wanted to achieve that by first creating the vlans, assigning subnets for them and then enabling routing between vlans globally on this switch.
Here is what I did:

```bash
SSH@Rigel(config)#vlan 10 name VLAN10
SSH@Rigel(config-vlan-10)#untagged eth 1/1/3 to 1/1/12 
Added untagged port(s) ethe 1/1/3 to 1/1/12 to port-vlan 10.
SSH@Rigel(config-vlan-10)#tagged eth 1/1/48
Added tagged port(s) ethe 1/1/48 to port-vlan 10.
SSH@Rigel(config-vlan-10)#ip-subnet 10.0.10.0/24
SSH@Rigel(config-vlan-ip-subnet)#
```

With that, I added ports 3 to 12 to the VLAN ID 10 and added what is typically a trunk port on the 48 port, and I assigned a subnet to this VLAN.
Here is the VLAN 20 configuration:

```bash
SSH@Rigel(config)#vlan 20 name PCs
SSH@Rigel(config-vlan-20)#tagged eth 1/1/48
Added tagged port(s) ethe 1/1/48 to port-vlan 20.
SSH@Rigel(config-vlan-20)#untagged eth 1/1/13 to 1/1/24
Added untagged port(s) ethe 1/1/13 to 1/1/24 to port-vlan 20.
SSH@Rigel(config-vlan-20)#ip-subnet 10.0.20.0/24
SSH@Rigel(config-vlan-ip-subnet)#
```

This is the cut output of `write terminal` command: ( It was cut to only include the important parts )

```bash
SSH@Rigel(config-vlan-ip-subnet)#write terminal
Current configuration:
!
ver 07.2.02aT7e1
!
stack unit 1
  module 1 fls-48-port-copper-base-module
  module 2 fls-cx4-1-port-10g-module
  module 3 fls-cx4-1-port-10g-module
!
!
!
!
vlan 1 name DEFAULT-VLAN by port
!
vlan 10 name VLAN10 by port
 tagged ethe 1/1/48 
 untagged ethe 1/1/3 to 1/1/12 
 ip-subnet 10.0.10.0 255.255.255.0
!
vlan 20 name PCs by port
 tagged ethe 1/1/48 
 untagged ethe 1/1/13 to 1/1/24 
 ip-subnet 10.0.20.0 255.255.255.0
```

After that, I wanted to try inter-vlan routing. So I tried to use the `ip routing` or `ip route` command in the global config level:

```bash
SSH@Rigel(config)#ip routing
Invalid input -> routing
Type ? for a list
SSH@Rigel(config)#ip route
Invalid input -> route
Type ? for a list
SSH@Rigel(config)#
```

This command `routing` or `route` seems to not even exist:

```bash
SSH@Rigel(config)#ip ?
  access-list                   Configure named access list
  address                       Set IP address
  arp                           Set ARP option
  default-gateway               Set IP default gateway
  dhcp                          Set DHCP option
  dhcp-client                   DHCP client address negotiation
  dhcp-server                   DHCP Server
  dns                           Set IP DNS
  icmp                          Control ICMP attacks
  igmp-report-control           Rate limit forwarding IGMP reports to upstream
                                Router, same as "ip multicast report-control"
  mtu                           Set IP MTU
  multicast                     Set IGMP snooping globally
  pimsm-snooping                Set PIMSM snooping globally
  preserve-acl-user-input-format
  show-acl-service-number       Use TCP/UDP service number to display ACL clause
  show-portname                 Use port name instead of interface number on
                                log messages
  show-service-number-in-log    Use App service number in log display
  show-subnet-length            Use subnet mask length to display IP subnet mask
  source                        Set source guard option
  ssh                           Configure Secure Shell
  ssl                           Configure Secure Socket
  tcp                           Control TCP SYN attacks           
  ttl                           Set IP TTL value
SSH@Rigel(config)#ip  
```

After some searching, I found that I should be in fact, able to use this command. This switch is L3 after all.
I checked the system:

```bash
SSH@Rigel#show ver
  Copyright (c) 1996-2010 Brocade Communications Systems, Inc.
    UNIT 1: compiled on Feb 16 2011 at 05:14:51 labeled as FGS07202a
                (2862535 bytes) from Primary FGS07202a.bin
        SW: Version 07.2.02aT7e1 
  Boot-Monitor Image size = 416213, Version:05.0.00T7e5 (Fev2)
  HW: Stackable FLS648 (PROM-TYPE FLS648-STK-U)
==========================================================================
UNIT 1: SL 1: FLS-48G 48-port Management Module
         Serial  #: M8AN23F00Z
         P-ENGINE  0: type D804, rev 01
         P-ENGINE  1: type D804, rev 01
==========================================================================
UNIT 1: SL 2: FLS-1XGC 1-port 10G Module (1-CX4)
==========================================================================
UNIT 1: SL 3: FLS-1XGC 1-port 10G Module (1-CX4)
==========================================================================
  400 MHz Power PC processor 8248 (version 130/2014) 66 MHz bus
  512 KB boot flash memory
30720 KB code flash memory
  256 MB DRAM
STACKID 1  system uptime is 2 hours 36 minutes 23 seconds 
The system : started=cold start  

SSH@Rigel#
```

Thats when I saw that the firmware is labeled as FGS07202a and *not as* **FLS07202a**.</br>
This might mean that for some unknown reason, my switch has a firmware from the GS series and not from the correct LS series. It basically functions probably because those switches might be similar on hardware level. But this lack of correct firmware, makes me unable to use the L3 options.

</br>
I copied the flash from the switch via TFTP to my laptop and opened it with HxD to see if I could see any clue.

![screenshot](flash-screenshot.png) </br>
At the end of the binary file I saw FGSL07202a. That string of letters is different from any that I saw earlier. It was either FLS or FGS, now it is FGSL. I have no idea for now why it is like that.</br>
So now it got really weird. The firmware is named FGS which ( read *Conclusion* ) should have basic L2 functionality and that is correct. But at the end of that binary file is a FGSL string which suggest that it should be a base L3 functions capable firmware. </br>
However, of course we saw that the L3 commands *do not work at all*.

## 02.03.2025
I may have found something.</br>

I did a lot of searching and in result I have found that the firmware name is in fact correct. Apparently the firmware for LS series is named like FGS, FGLS and FGSR. There is no FLS firmware. </br>
The downloads for the firmware are no longer available because first they were only for premium users and additionally the company that made them doesn’t exist anymore. I have found a single working link on some very old post on Reddit. It was uploaded by Fohdeesha. The link was a mirror download for a folder with the firmware’s for the whole FastIron series. </br>
This screenshot is something that finally gave me some kind of a clue. Well, not only some clue but this really confirmed that the switch *is aware that it can do L3*. Or more precisely, that there are more versions of the firmware for this switch.</br>
![alt text](errorcode8.png)</br>
Here is what actually happened and what this meant. After I downloaded the folder with the firmwares and located where were the LS firmwares, I moved it to my TFTP directory and tried to load it into flash using `copy` command:

```bash
Rigel#copy tftp flash 10.0.0.113 FGSR07202r.bin primary
Rigel#You cannot load Edge L3 code on this hardware. Please upgrade the license.
File Type Check failed
TFTP to Flash error - code 8
```

Looks like the FGSR version of this firmware is not possible to load without a suitable license. Of course, I cannot do that because of obvious reason. However I searched some mode and by typing "FLS648" on the search bar on the <a href="https://fohdeesha.com/docs/">Fohdeesha docs</a> website, I found some information that specified how to manually trick the switch into thinking that it has a license enabled.</br>

This part of the process consisted of manually byte-by-byte inserting a "magic string" into the flash. The command allowing us to do so, is `i2cWriteByte`. However, this command does not work in the typical level of the terminal. So I had to use a serial connection and the after logging into privelaged mode I had to click **Ctrl+Y** and **Ctrl+M** and **Enter**. After doing so, the command prompt turned from `FLS648` into `FLS-Monitor`. This is where I could use the command for manually writing data into the switch. </br>

Below are the commands I had to input. They were used to manually write the **magic string** which tells the switch that it has an active L3 license *( it doesn't )*.</br>

</br>

```js
FLS-Monitor>i2cWriteByte 40 0 fe
i2c write to address 0x40 offset 0x0 value Oxfe --- PASS
FLS-Monitor>i2cWriteByte 40 l ed
i2c write to address 0x40 offset Oxl value Oxed --- PASS
FLS-Monitor>i2cWriteByte 40 2 fa
i2c write to address 0x40 offset 0x2 value Oxfa --- PASS
FLS-Monitor>i2cWriteByte 40 3 ce
i2c write to address 0x40 offset 0x3 value 0xce --- PASS
FLS-Monitor>i2cWriteByte 40 4 1
i2c write to address 0x40 offset 0x4 value 0xl --- PASS
FLS-Monitor>12cWriteByte 40 5 0
i2c write to address 0x40 offset 0x5 value 0x0 --- PASS
FLS-Monitor>i2cWriteByte 40 6 1
i2c write to address 0x40 offset 0x6 value 0x1 --- PASS
FLS-Monitor>i2cWriteByte 40 7 0
i2c write to address 0x40 offset 0x7 value 0x0 --- PASS
FLS-Monitor>

```

This is possible to do, because old Brocade switches *( like the FastIron series )*, had hardware licensing mechanism. There is a EEPROM chip in the main board inside the switch ( technically two of them but only one is removable ). The removable one stores the magic string and tells the switch whether the license is active or not. Nowadays of course, switches have software licensing. What I did here is not possible in those newer switches.
</br>

I also read that it was in fact possible to buy that EEPROM chip on your own along with a programmer. Sadly, the only page that offered those, **is long gone**. Maybe *( but **very** unlikely )* it's still possible to get those specific chips, but I hardly think that has any sense, especially now, in 2025.

</br>

**( I will put a photo of the mobo here )**

![mobo](/issues@homelab/Brocade-FLS648-firmware-issue/FLS648-mobo.jpeg)



I will provide the folder here in this repository in case the only available mirror link goes down. 

</br>

**( more info coming here soon... )**


# Conclusion 

Turns out, **the firmware wasn’t incorrect**. It was named correctly and *it was* made for this switch. However, there were three versions of it. FGS, FGLS and FGSR. Each of them could have an „a” or a „r” letter at the end. The ones with „a” were compiled in 2011 and the ones with „r” in 2015.</br>
The „FGS” version is only L2. That was the reason why I wasn’t able to use commands such as `ip route`. This firmware didn’t even have that command implemented.
</br>
Also, what is common when buying a datacenter or enterprise-grade network hardware, you need a license to use L3 features. 
</br>
Of course they 99% of the time, are impossible to obtain by regular people. And even if in this particular scenario, a license for L3 was possible to get, the company that could issue a license, doesn’t even exist anymore. 
</br>
I think I will try to write my own tutorial for the sake of it. 
Maybe someone starting with a lab will buy that switch, because they are dirt cheap and are a great way to get along with CLI instead of typical GUI. </br>
And they seem like they never ever existed on the internet. There is only a brochure, maybe like 5 posts about them and a 90 page document about the FastIron LS / LS-STK series from Brocade, year 2011. Otherwise, a community about this switch is extinct I guess. I searched a lot a found absolutely no info whatsoever about the 2015 release of the firmware.
</br>
The firmwares were like following:

- FGS07202a.bin - Base L2 functionality 
- FGLS07202a.bin - Base L3 functionality 
- FGSR07202a.bin - Edge L3 functionality
