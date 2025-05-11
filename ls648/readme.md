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
</div>
The switch is not capable of L3 functionality with the default firmware. 
To enable L3 features, you need to flash the switch with a different firmware version. 
The process is not straightforward and requires some technical knowledge.  
The firmware file is pretty much impossible to find on the internet. There is one single forum on which I was able to find the firmware image.
Out-of-the-box, the switch comes with a firmware named **`FGS07202a.bin`**. I was able to make a backup of this image if anything went wrong.
 The firmware capable of L3 functionality is named **`FGS07202r.bin`**.