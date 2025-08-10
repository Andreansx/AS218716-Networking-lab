# 2025-08-10 14:12:22 by RouterOS 7.19.4
# system id = dJn1z08G2hD
#
/interface ethernet
set [ find default-name=ether3 ] disable-running-check=no name=etherLanCorp
set [ find default-name=ether2 ] disable-running-check=no name=etherLanGuest
set [ find default-name=ether4 ] disable-running-check=no name=etherMgmt
set [ find default-name=ether1 ] disable-running-check=no name=etherWAN
/ip pool
add name=PoolLanCorp ranges=192.168.88.100-192.168.88.200
add name=PoolLanGuest ranges=172.16.0.100-172.16.0.200
/ip dhcp-server
add address-pool=PoolLanCorp interface=etherLanCorp name=DhcpLanCorp
add address-pool=PoolLanGuest interface=etherLanGuest name=DhcpLanGuest
/ip address
add address=192.168.88.1/24 interface=etherLanCorp network=192.168.88.0
add address=172.16.0.1/24 interface=etherLanGuest network=172.16.0.0
/ip dhcp-client
add interface=etherWAN
/ip dhcp-server network
add address=172.16.0.0/24 dns-server=172.16.0.1 gateway=172.16.0.1
add address=192.168.88.0/24 dns-server=192.168.88.1 gateway=192.168.88.1
/ip dns
set servers=1.1.1.1,8.8.8.8
/ip firewall filter
add action=accept chain=forward connection-state=established,related \
add action=accept chain=input connection-state=established,related
add action=accept chain=input port=22,8291 protocol=tcp \
    src-address=192.168.88.0/24
add action=accept chain=forward dst-address=172.16.0.0/24 \
    src-address=192.168.88.0/24
add action=drop chain=forward dst-address=192.168.88.0/24 \
    src-address=172.16.0.0/24
add action=accept chain=forward out-interface=etherWAN
add action=drop chain=forward
add action=drop chain=input
/ip firewall nat
add action=masquerade chain=srcnat out-interface=etherWAN
/system ntp client
set enabled=yes
/system ntp client servers
add address=0.pl.pool.ntp.org
