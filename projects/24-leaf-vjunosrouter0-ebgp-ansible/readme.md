# eBGP on Leaf-vJunosRouter0 using Ansible

In the previous documentation I used Ansible for the first time in a project to set the MTUs on the interfaces.   
You can read it [here](../23-jumbo-frames/)    

I'm gonna be connecting Leaf-vJunosRouter0 to Spine-DellEMCS4048-ON0 using eBGP.   

Spine-DellEMCS4048-ON0 is AS4200000000 and Leaf-vJunosRouter0 will be AS4201000000.  

Those devices will be connected through a dedicated 10GbE link instead of how I previously used a Trunk link for a few point-to-points over a single physical cable.   

On the Spine-DellEMCS4048-ON0 side it's `172.16.255.4/3` and on the Leaf-vJunosRouter0 it's `.5`.   

Spine-DellEMCS4048-ON0 RID is `172.16.0.0` and Leaf-vJunosRouter0 is gonna be `172.16.1.0`.   

So this time I won't show how I'm entering commands in Junos one by one and instead I will show what I'm adding to the Ansible playbook.   

The beginning is the same as the last time:   
```yaml
---
- name: Provisioning Leaf-vJunosRouter0 with eBGP config 
  hosts: Leaf-vJunosRouter0
  connection: netconf 
  gather_facts: no 
  collections:
    junipernetworks.junos
```

I'll also use variables instead of hardcoding everything.   
```yaml
  
  vars:
    bgp_interfaces:
      - name: ge-0/0/0 
        address: 172.16.255.5/31
        desc: eBGP link 0 to Spine-DellEMCS4048-ON0
    bgp:
      rid: 172.16.1.0 
      system_as: 4201000000
      neighbors:
        - ip: 172.16.255.4
          remote-as: 4200000000
```

The first task is going to be setting up the uplink interface to Spine-DellEMCS4048-ON0 on the Leaf-vJunosRouter0.   

```yaml
tasks:
  - name: Setting up the uplink interface
    junipernetworks.junos.junos_config:
      lines:
        - "set interfaces {{ item.name }} unit 0 family inet address {{ item.address }}"
      comment: "Applied address {{ item.address }} to interface {{ item.name }}"
    register: result_task1
    loop: "{{ bgp_interfaces }}"

```
This is pretty similar to how I used a loop in the [last](../23-jumbo-frames/) documentation.   
The `bgp_interfaces` is a list which consists of only one interface for now but the point is that it is easily scalable.   
Each element of the `bgp_interfaces` list consists of a `name` and `address`.  
So by iterating through the elements in the `bgp_interfaces` list, I can easily apply the same command to a bunch of interfaces.   
On the first iteration of the loop through the `bgp_interfaces` list, the value of `item.name` field is equal to `ge-0/0/0` and the value of `item.address` is `172.16.255.5/31`.   
If I used only `item` then theoretically it would input both the `name` and the `address` into the `{{ item }}` field.   

The usage of `{{ item.name }}` and `{{ item.address }}` goes the same for the `comment` part.    

And of course we register the result of the task as `result_task1`.  

Then the next task is to add an ASN to the Leaf-vJunosRouter0.  
```yaml
    - name: Configuring eBGP 
      junipernetworks.junos.junos_config:
        lines:
          - "set routing-options autonomous-system {{ bgp.system_as }}"  
        comment: "Assigned an ASN of {{ bgp.system_as }}"
```
