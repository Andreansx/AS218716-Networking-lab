# Basic Day0 config on the Dell EMC S4048-ON  

Just wanted to show how I set up a basic config for SSH access on the Dell S4048-ON.   

First I plugged my RJ45 Serial to USB-A adapter into my laptop and into the console port on the Dell S4048-ON:   

![console](./console.jpeg)   

I also already connected the Management port on the Dell S4048-ON to one of the free 1GbE ports in my Dell R710.   
Refer to the [Out-of-Band Management](../19-oob-mgmt/readme.md) Project.   

![r710-ports](./r710-ports.jpeg)   

The white cable on the rightmost of the photo is the one connecting the `OVS_OOB` to the Dell S4048-ON.
