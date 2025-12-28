# DHCP Failing on RouterOS v7 and Debian 13.

This will be a case study about an issue I had recentyl.  

Basically there was a Dell T620 Plus mini PC in my lab.
I connected it to the Brocade FLS648 switch and I removed one BGP link between the CRS326 and CCR2004 so I could connect the CRS326 to the FLS648.

I set the `sfp-sfpplus2` interface on the CRS326 to be a untagged port for the VLAN 40 so that the whole FLS648 would be a single L2 domain.
Then I plugged the T620 into the FLS648.   

There was a DHCP Relay on SVI40 on the CRS326 and a DHCP Server listening on bridge0 on the CCR2004.

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
gru 27 20:28:27 t620plus NetworkManager[712]: <info>  [1766863707.1974] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:29:12 t620plus NetworkManager[712]: <info>  [1766863752.1636] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:29:12 t620plus NetworkManager[712]: <info>  [1766863752.1637] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:29:12 t620plus NetworkManager[712]: <info>  [1766863752.1637] dhcp4 (enp1s0): state changed no lease
gru 27 20:34:12 t620plus NetworkManager[712]: <info>  [1766864052.2352] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:34:57 t620plus NetworkManager[712]: <info>  [1766864097.1594] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:34:57 t620plus NetworkManager[712]: <info>  [1766864097.1594] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:34:57 t620plus NetworkManager[712]: <info>  [1766864097.1595] dhcp4 (enp1s0): state changed no lease
gru 27 20:34:57 t620plus NetworkManager[712]: <info>  [1766864097.1983] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:35:42 t620plus NetworkManager[712]: <info>  [1766864142.1594] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:35:42 t620plus NetworkManager[712]: <info>  [1766864142.1595] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:35:42 t620plus NetworkManager[712]: <info>  [1766864142.1596] dhcp4 (enp1s0): state changed no lease
gru 27 20:35:42 t620plus NetworkManager[712]: <info>  [1766864142.1780] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:36:27 t620plus NetworkManager[712]: <info>  [1766864187.1596] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:36:27 t620plus NetworkManager[712]: <info>  [1766864187.1597] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:36:27 t620plus NetworkManager[712]: <info>  [1766864187.1597] dhcp4 (enp1s0): state changed no lease
gru 27 20:36:27 t620plus NetworkManager[712]: <info>  [1766864187.1777] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:37:12 t620plus NetworkManager[712]: <info>  [1766864232.1554] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:37:12 t620plus NetworkManager[712]: <info>  [1766864232.1555] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:37:12 t620plus NetworkManager[712]: <info>  [1766864232.1556] dhcp4 (enp1s0): state changed no lease
gru 27 20:42:12 t620plus NetworkManager[712]: <info>  [1766864532.2354] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:42:57 t620plus NetworkManager[712]: <info>  [1766864577.1675] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:42:57 t620plus NetworkManager[712]: <info>  [1766864577.1676] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:42:57 t620plus NetworkManager[712]: <info>  [1766864577.1677] dhcp4 (enp1s0): state changed no lease
gru 27 20:42:57 t620plus NetworkManager[712]: <info>  [1766864577.2072] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:43:42 t620plus NetworkManager[712]: <info>  [1766864622.1594] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:43:42 t620plus NetworkManager[712]: <info>  [1766864622.1595] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:43:42 t620plus NetworkManager[712]: <info>  [1766864622.1595] dhcp4 (enp1s0): state changed no lease
gru 27 20:43:42 t620plus NetworkManager[712]: <info>  [1766864622.1805] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:44:27 t620plus NetworkManager[712]: <info>  [1766864667.1594] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:44:27 t620plus NetworkManager[712]: <info>  [1766864667.1595] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:44:27 t620plus NetworkManager[712]: <info>  [1766864667.1595] dhcp4 (enp1s0): state changed no lease
gru 27 20:44:27 t620plus NetworkManager[712]: <info>  [1766864667.1891] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:45:12 t620plus NetworkManager[712]: <info>  [1766864712.1595] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:45:12 t620plus NetworkManager[712]: <info>  [1766864712.1596] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:45:12 t620plus NetworkManager[712]: <info>  [1766864712.1596] dhcp4 (enp1s0): state changed no lease
gru 27 20:45:38 t620plus NetworkManager[712]: <info>  [1766864738.2347] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:46:23 t620plus NetworkManager[712]: <info>  [1766864783.1756] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:46:23 t620plus NetworkManager[712]: <info>  [1766864783.1757] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:46:23 t620plus NetworkManager[712]: <info>  [1766864783.1758] dhcp4 (enp1s0): state changed no lease
gru 27 20:46:23 t620plus NetworkManager[712]: <info>  [1766864783.2015] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:47:08 t620plus NetworkManager[712]: <info>  [1766864828.1675] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:47:08 t620plus NetworkManager[712]: <info>  [1766864828.1676] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:47:08 t620plus NetworkManager[712]: <info>  [1766864828.1677] dhcp4 (enp1s0): state changed no lease
gru 27 20:47:08 t620plus NetworkManager[712]: <info>  [1766864828.1967] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:47:53 t620plus NetworkManager[712]: <info>  [1766864873.1554] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:47:53 t620plus NetworkManager[712]: <info>  [1766864873.1555] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:47:53 t620plus NetworkManager[712]: <info>  [1766864873.1556] dhcp4 (enp1s0): state changed no lease
gru 27 20:47:53 t620plus NetworkManager[712]: <info>  [1766864873.1823] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:48:38 t620plus NetworkManager[712]: <info>  [1766864918.1554] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:48:38 t620plus NetworkManager[712]: <info>  [1766864918.1555] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:48:38 t620plus NetworkManager[712]: <info>  [1766864918.1555] dhcp4 (enp1s0): state changed no lease
gru 27 20:49:45 t620plus NetworkManager[712]: <info>  [1766864985.4460] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:50:31 t620plus NetworkManager[712]: <info>  [1766865031.1676] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:50:31 t620plus NetworkManager[712]: <info>  [1766865031.1677] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:50:31 t620plus NetworkManager[712]: <info>  [1766865031.1677] dhcp4 (enp1s0): state changed no lease
gru 27 20:50:31 t620plus NetworkManager[712]: <info>  [1766865031.2099] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:51:16 t620plus NetworkManager[712]: <info>  [1766865076.1675] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:51:16 t620plus NetworkManager[712]: <info>  [1766865076.1676] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:51:16 t620plus NetworkManager[712]: <info>  [1766865076.1677] dhcp4 (enp1s0): state changed no lease
gru 27 20:51:16 t620plus NetworkManager[712]: <info>  [1766865076.2077] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:52:01 t620plus NetworkManager[712]: <info>  [1766865121.1434] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:52:01 t620plus NetworkManager[712]: <info>  [1766865121.1436] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:52:01 t620plus NetworkManager[712]: <info>  [1766865121.1437] dhcp4 (enp1s0): state changed no lease
gru 27 20:52:01 t620plus NetworkManager[712]: <info>  [1766865121.1690] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:52:46 t620plus NetworkManager[712]: <info>  [1766865166.1675] dhcp4 (enp1s0): canceled DHCP transaction
gru 27 20:52:46 t620plus NetworkManager[712]: <info>  [1766865166.1676] dhcp4 (enp1s0): activation: beginning transaction (timeout in 45 seconds)
gru 27 20:52:46 t620plus NetworkManager[712]: <info>  [1766865166.1676] dhcp4 (enp1s0): state changed no lease
```

