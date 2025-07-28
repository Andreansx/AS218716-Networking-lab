# Project: Repurposing a NIC for Cost-Effective VLAN Access Ports on Proxmox VE

This document outlines the process of turning a Proxmox VE server into a software-defined switch to provide secure, segregated network access, avoiding the high cost of dedicated hardware.

## 1. Background and Objective

The primary goal was to provide wired network connectivity to another room. To achieve this, I had already run two high-quality **Cat6A Cu** ethernet cables through the wall, terminating them with keystone jacks.

The most straightforward hardware approach would have been to use two SFP+ 10G-RJ45 transceivers in free ports on my Mikrotik CRS326 switch. However, the cost of MikroTik-branded 10G-RJ45 SFPs made this really impractical for me. 

This led me to a more creative, software-defined objective:
- **Achieve the same result by repurposing a spare, dual-port 10GbE RJ45 NIC that was currently collecting dust.**
- **Implement the entire solution at the hypervisor level (Proxmox VE), leveraging its networking capabilities.**
- **Ensure that any device connected to these new ports is automatically and securely placed into the isolated `VLAN 30` (Users).**

## 2. Environment & Hardware

- **Server**: Dell PowerEdge R710
- **Hypervisor**: Proxmox VE 8.4.5
- **Core Switch**: Mikrotik CRS326-24S+2Q+RM
- **Cabling**: 2x Cat6A Cu runs installed through the wall.
- **Uplink NIC (existing)**: 1x 10GbE SFP+ (System Name: `enp6s0`)
- **Repurposed Access NIC**: 1x Dual-port 10GbE RJ45 (System Names: `enp7s0f0`, `enp7s0f1`)
- **Target VLAN**: `VLAN 30` (Users network)
