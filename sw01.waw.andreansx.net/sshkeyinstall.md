```OS10
OS10# system bash
admin@OS10:/home/admin$ sudo ip netns exec management wget http://10.1.99.191:8000/Ansible_fabric_automation_ed25519.pub -O /home/admin/Ansible_fabric_automation_ed25519.pub
--2026-02-28 13:01:40--  http://10.1.99.191:8000/Ansible_fabric_automation_ed25519.pub
Connecting to 10.1.99.191:8000... connected.
HTTP request sent, awaiting response... 200 OK
Length: 102 [application/vnd.exstream-package]
Saving to: ‘/home/admin/Ansible_fabric_automation_ed25519.pub’

/home/admin/Ansible 100%[===================>]     102  --.-KB/s    in 0s      

2026-02-28 13:01:40 (6.74 MB/s) - ‘/home/admin/Ansible_fabric_automation_ed25519.pub’ saved [102/102]

admin@OS10:/home/admin$ ls
Ansible_fabric_automation_ed25519.pub
admin@OS10:/home/admin$ exit
exit
OS10# dir home
  
Directory contents for folder: home
Date (modified)        Size (bytes)  Name
---------------------  ------------  ------------------------------------------
2026-02-28T12:20:54+00:102           Ansible_fabric_automation_ed25519.pub                                           
OS10# configure terminal
OS10(config)# username ansible sshkey 
  filename  File that contains SSH key string
  String    SSH key string
OS10(config)# username ansible sshkey filename /home/admin/Ansible_fabric_automation_ed25519.pub
```
