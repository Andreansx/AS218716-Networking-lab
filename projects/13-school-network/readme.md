# School Network


Basically, a couple weeks ago, my school was supposedly hit by lightning during a storm.  

It seems that the strike was pretty powerful since it fried a switch in the school network.
At the same time, wireless network went completely down since the Access Points were powered by PoE.   

I won't go into the details of problems that I had with getting into a agreement with the school and I will just document what I can stricttly about the network here.  

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
That is probably the reason for constant broadcast storm










