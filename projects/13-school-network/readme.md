# School Network

Description of the process of fixing the school network and what I uncovered.

> [!IMPORTANT]   
> I want to make one thing very very clear. I know that this school network was configured as a **PhD project** of one of the students of a nearby university on a telecommunications profile.  
> In case that you recognized this network and you are that person, I want to you to know that I **am not hating** in any way on your work.  
> It's the last thing I want this to be perceived as.  
> I absolutely admire your work and the only thing I want to state here is that the equipment is simply old. 
> Some of the networking devices are almost 15 years old. 100Mbps bottleneck connections for five hundred students in a school just cannot be even remotely enough in todays world.   
> Just please know that this is absolutely not criticism and I don't want anyone to think that I am some kind of an arrogant person.

Basically, a couple weeks ago, my school was supposedly hit by lightning during a storm.  

It seems that the strike was pretty powerful since it fried a switch in the school network.
At the same time, wireless network went completely down since the Access Points were powered by PoE.   

I won't go into the details of problems that I had with getting into a agreement with the school and I will just document what I can stricttly about the network here.  

I want to also state here that problems with the school network began already some time ago and the lost wireless access was not the main cause. It is just another issue.


The networking equipment was founded by the European Union and I do not know if I can post photos of it here, so I will check with the IT teacher if I can do that.  
He basically knew that I am a networking enthusiast so he asked my friend to ask me if I can fix their WiFi.   

This all will be more of a flow of thoughts rather than a full documentation but I will try to make everything as clean as I can.

## How this started

Around the start of October, my friend texted me that the IT teacher wants to know if I will be able to configure 11 Cisco Access Points. 
I was kinda suprised since my networking skills actually never really found a usage in my school. 
I went to school the next day and I talked with the IT teacher about that. 
The first and most important thing at that point which I asked about, was the type of the Access Points, since if he bought a lightweight APs and didn't buy a WLC, then those APs would be useless without that WLC.   

I asked "are those APs autonomic, or do they need a controller?".    
He said that they are autonomic.  
Then I thought that managing 11 APs separately will be really hard when changing passwords etc.   
So I asked "When changing the password to the wifi, did you have to log into each AP, or did you change the password in one place?"   
He said that he just needed to change it in one place.   

So as you may suspect, I got really confused and I just knew that I have to find out most of the things by myself.   

## Next steps


A couple days later, I had IT class so I waited for him to come up to me and say some more information etc.  

Then he showed me the schools networking rack so I was finally able to see what I would be dealing with.   

As I stated above, I do not know if it's legal if I post a photo of European Union-issued networking gear so I won't post any photos for now.   

The topology there is actually kind of complicated.    
Complicated as in a lot of cables and devices from completely different brands, and not as in a lot of dynamic routing etc.   

One thing that really grossed me out some time ago was that the PCs in the school were in a `/23` subnet.    
That is probably the reason for long-standing constant broadcast storm.    


So back to the wifi problem, I went up on a ladder to get near the rack and I just looked at how everything is connected etc.  

Keep in mind I do not have any kind of a diagram or even an IP Addressation table provided so it takes some time to figure out everything.   

He showed me which switch was fried and into which the APs were plugged into.   

It looks to be a Cisco Catalyst 3850 24 PoE+.  

I wanted to see where the WLC was, but there was none.   
This confused me since, from what I found later, the APs (`AIR-CAP2602I-E-K9`) were a lightweight model which makes them usable only with a Wireless LAN Controller.   

However, at home I looked more into the Catalyst 3850.  
At first it seemed like a typical L3 switch with PoE.
It was sold in versions including 24 or even 48 PoE+ RJ45 ports and it had a non-blocking capacity of 146Gbps.   

I then remembered that the IT teacher said something about managing the APs from the switch.

So I checked the available firmwares for the Catalyst 3850 and surely to my suprise there really is a WLC firmware for it.   
I never saw a switch like that ever.   

So this finally explained why the APs were lightweight and there was seemingly no WLC.

This means that they not only lost just a switch but also a Controller. 

Later the IT teacher handed me one of the APs and told me to take it home and try to reset it and create a basic wifi on it.   
I told him that I do not have any devices capable of delivering PoE power so he gave me a PoE injector and I took it home.   


At home I plugged a utp cable from the PoE injector to the AP and surely enough it started blinking white for a second, then green.  

Meanwhile I had established a console connection from my laptop through a Cisco RJ45 Console cable to the AP. 
I used the simplest way of doing that, which is using the `screen` command on linux.   

First I had to check the name of the USB device to be sure on which line I should expect a serial connection.

```bash
❯ sudo dmesg | grep tty
! output ommited
[ 2549.224986] usb 1-3: FTDI USB Serial Device converter now attached to ttyUSB0
```
Then I simply run screen with 9600 baud:

```bash
screen /dev/ttyUSB0 9600
```

As I was expecting to see some boot logs, I got none.  

I tried different baud speeds but nothing seemed to work. 
From what I read in the documentation for that AP, it should display boot logs even though it's a lightweight model.

I still do not know if it is fried but I think this might be the first indicator that the lightning strike fried the AP since it was connected through PoE.  
Of course I checked the serial connection several times and also checked it on different devices and this ensured that the console cable is not faulty.  

The AP when powered on, blinks green for a solid 1-2 minutes, then goes to blinking red.    

You can see the green light on it here where I placed it in my rack:   

![green](./green.JPEG)   

Here you can see the red light. It was blinking but I didn't take a video:   

![red](./red.JPEG)

I read the Cisco Documenation and from what I learned, the red blinking light indicates that there is a hardware problem.   
I do not have any kind of confirmation that the AP worked after the lightning strike.  

And I do not want to make such assumtions but it's just that the AP seems pretty fried to me. 
I hope that it is not, but those two things just make me really confused about whereas is it working or not.   

![ap](./ap.JPEG)    


Next day I returned the AP and told the teacher that I wasn't able to do anything with it because of two reasons.   
The first one being the lightweight mode of the AP, and the second being the assumption that the AP has been damaged along with the switch.   

We went to the server room and he told me a bit more about the network.  
I basically told him that he was right about managing the APs from the switch. 
It was just a rare model which functionality I haven't heard about much.

I told him that I think that it's best if we use a separate device as a controller instead of using the controller on the switch.  
He said that he will take that fried switch and give it to someone to try and fix it and if it will be fixed, then end of story and the network will work again.   

However I just doubt that someone will bring that switch back to life since, after all, it was fried by a literal lightning strike and the APs were probably fried along with it.   

Great thing is that he told me to look up some devices that we should buy to fix the network.   

I wanted to get an used CT2504 or a CT3504. 
Those models are small, power-efficent, quiet and have enough capacity to handle a lot of users on 11 APs.  

However, the number of APs is the issue here.  
Cisco does not allow to configure more than 5 APs on an WLC without an additional license.

## Presumed cons of a new network plan


I actually have some worries regarding the IT teachers plans for "modernizing" the network.   

First thing is that currently (even though wireless network does not work) the network is segmented to some extent with VLANs. 
In todays networking, VLANs are not even a good practice anymore. 
VLANs are an absolute must-have in any bigger-than-home network.  





## Contact

[![Telegram](https://img.shields.io/badge/telegram-2B59FF?style=for-the-badge&logo=telegram&logoColor=ffffff&logoSize=auto)](https://t.me/Andrtexh)
