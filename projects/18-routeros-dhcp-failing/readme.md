# DHCP Failing on RouterOS v7 and Debian 13.

This will be a case study about an issue I had recentyl.  

Basically there was a Dell T620 Plus mini PC in my lab.
I connected it to the Brocade FLS648 switch and I removed one BGP link between the CRS326 and CCR2004 so I could connect the CRS326 to the FLS648.

I set the `sfp-sfpplus2` interface on the CRS326 to be a untagged port for the VLAN 40 so that the whole FLS648 would be a single L2 domain.
Then I plugged the T620 into the FLS648.   

There was a DHCP Relay on SVI40 on the CRS326 and a DHCP Server listening on bridge0 on the CCR2004.

I don't actually remember everything in detail now but basically the T620 could not get access to the network because of not claiming an address from DHCP.
At first I blamed the T620 because it was hard for me to believe that the CCR2004 and CRS326 could be at fault.
After all this hardware isn't the typical consumer-grade network stuff but rather something that could actually provide internet access for a small branch office or maybe a small local ISP *(but with a lightened BGP table as the CCR2004 only has 4GB of RAM)*.   

But it became clear that it wasn't the fault of the T620 when I plugged it into a wifi router from my ISP and it automatically connected to Tailscale which made it obvious that it must have acquired an IP address from the DHCP running on the wifi router.


```bash
sudo journalctl -b -5 | grep -i dhcp
gru 27 20:11:05 t620plus NetworkManager[712]: <info>  [1766862665.7795] dhcp: init: Using DHCP client 'internal'
gru 27 20:11:08 t620plus NetworkManager[712]: <info>  [1766862668.4708] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:11:54 t620plus NetworkManager[712]: <info>  [1766862714.1514] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:11:54 t620plus NetworkManager[712]: <info>  [1766862714.1515] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:11:54 t620plus NetworkManager[712]: <info>  [1766862714.1515] dhcp4 (enp1s0): state changed no lease
gru 27 20:11:54 t620plus NetworkManager[712]: <info>  [1766862714.1986] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:12:39 t620plus NetworkManager[712]: <info>  [1766862759.1594] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:12:39 t620plus NetworkManager[712]: <info>  [1766862759.1595] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:12:39 t620plus NetworkManager[712]: <info>  [1766862759.1595] dhcp4 (enp1s0): state changed no lease
gru 27 20:12:39 t620plus NetworkManager[712]: <info>  [1766862759.2325] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:13:24 t620plus NetworkManager[712]: <info>  [1766862804.1554] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:13:24 t620plus NetworkManager[712]: <info>  [1766862804.1555] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:13:24 t620plus NetworkManager[712]: <info>  [1766862804.1555] dhcp4 (enp1s0): state changed no lease
gru 27 20:13:24 t620plus NetworkManager[712]: <info>  [1766862804.1790] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:14:09 t620plus NetworkManager[712]: <info>  [1766862849.1795] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:14:09 t620plus NetworkManager[712]: <info>  [1766862849.1796] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:14:09 t620plus NetworkManager[712]: <info>  [1766862849.1796] dhcp4 (enp1s0): state changed no lease
gru 27 20:15:45 t620plus NetworkManager[712]: <info>  [1766862945.7601] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:16:31 t620plus NetworkManager[712]: <info>  [1766862991.1594] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:16:31 t620plus NetworkManager[712]: <info>  [1766862991.1595] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:16:31 t620plus NetworkManager[712]: <info>  [1766862991.1595] dhcp4 (enp1s0): state changed no lease
gru 27 20:16:31 t620plus NetworkManager[712]: <info>  [1766862991.1886] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:17:16 t620plus NetworkManager[712]: <info>  [1766863036.1554] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:17:16 t620plus NetworkManager[712]: <info>  [1766863036.1555] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:17:16 t620plus NetworkManager[712]: <info>  [1766863036.1555] dhcp4 (enp1s0): state changed no lease
gru 27 20:17:16 t620plus NetworkManager[712]: <info>  [1766863036.1814] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:18:01 t620plus NetworkManager[712]: <info>  [1766863081.1594] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:18:01 t620plus NetworkManager[712]: <info>  [1766863081.1595] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:18:01 t620plus NetworkManager[712]: <info>  [1766863081.1595] dhcp4 (enp1s0): state changed no lease
gru 27 20:18:01 t620plus NetworkManager[712]: <info>  [1766863081.1774] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:18:46 t620plus NetworkManager[712]: <info>  [1766863126.1677] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:18:46 t620plus NetworkManager[712]: <info>  [1766863126.1678] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:18:46 t620plus NetworkManager[712]: <info>  [1766863126.1679] dhcp4 (enp1s0): state changed no lease
gru 27 20:20:33 t620plus NetworkManager[712]: <info>  [1766863233.8296] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:21:19 t620plus NetworkManager[712]: <info>  [1766863279.1635] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:21:19 t620plus NetworkManager[712]: <info>  [1766863279.1636] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:21:19 t620plus NetworkManager[712]: <info>  [1766863279.1637] dhcp4 (enp1s0): state changed no lease
gru 27 20:21:19 t620plus NetworkManager[712]: <info>  [1766863279.1879] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:22:04 t620plus NetworkManager[712]: <info>  [1766863324.1717] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:22:04 t620plus NetworkManager[712]: <info>  [1766863324.1718] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:22:04 t620plus NetworkManager[712]: <info>  [1766863324.1719] dhcp4 (enp1s0): state changed no lease
gru 27 20:22:04 t620plus NetworkManager[712]: <info>  [1766863324.1903] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:22:49 t620plus NetworkManager[712]: <info>  [1766863369.1594] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:22:49 t620plus NetworkManager[712]: <info>  [1766863369.1595] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:22:49 t620plus NetworkManager[712]: <info>  [1766863369.1596] dhcp4 (enp1s0): state changed no lease
gru 27 20:22:49 t620plus NetworkManager[712]: <info>  [1766863369.1789] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:23:34 t620plus NetworkManager[712]: <info>  [1766863414.1554] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:23:34 t620plus NetworkManager[712]: <info>  [1766863414.1555] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:23:34 t620plus NetworkManager[712]: <info>  [1766863414.1556] dhcp4 (enp1s0): state changed no lease
gru 27 20:26:11 t620plus NetworkManager[712]: <info>  [1766863571.7380] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:26:57 t620plus NetworkManager[712]: <info>  [1766863617.1595] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:26:57 t620plus NetworkManager[712]: <info>  [1766863617.1595] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:26:57 t620plus NetworkManager[712]: <info>  [1766863617.1596] dhcp4 (enp1s0): state changed no lease
gru 27 20:26:57 t620plus NetworkManager[712]: <info>  [1766863617.2091] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:27:42 t620plus NetworkManager[712]: <info>  [1766863662.1514] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:27:42 t620plus NetworkManager[712]: <info>  [1766863662.1515] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:27:42 t620plus NetworkManager[712]: <info>  [1766863662.1515] dhcp4 (enp1s0): state changed no lease
gru 27 20:27:42 t620plus NetworkManager[712]: <info>  [1766863662.1817] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:28:27 t620plus NetworkManager[712]: <info>  [1766863707.1675] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:28:27 t620plus NetworkManager[712]: <info>  [1766863707.1676] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:28:27 t620plus NetworkManager[712]: <info>  [1766863707.1676] dhcp4 (enp1s0): state changed no lease
```

