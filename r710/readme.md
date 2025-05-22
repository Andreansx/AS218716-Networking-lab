# Overview of my Dell R710 server

## Specs
*   **CPU:** 2x Intel Xeon X5670 
*   **C/T:** 12C/24T
*   **Memory:** 128 GB DDR3 ECC Skhynix & Samsung
*   **Disk space:** Combined 1.6 TB of HDD SAS disk space

## System
**This server is running Proxmox Virtual Environment version 8.4.1**
```sh
root@r710homelab ~
# uname -a
Linux r710homelab 6.8.12-10-pve #1 SMP PREEMPT_DYNAMIC PMX 6.8.12-10 (2025-04-18T07:39Z) x86_64 GNU/Linux
```
## Related files
* **[BIOS 6.6.0](./BIOS_0F4YY_LN_6.6.0.BIN) - BIOS image to flash using iDRAC**
* **[BIOS 6.6.0](./BIOS_0YV9D_LN_6.6.0.BIN) - BIOS image to flash using iDRAC**
* **[All in one](./r-710-bootable_archive.torrent) - .exe file to update every firmware on the R710. Including Lifecycle controller, BIOS, RAID controller. Needs to be executed with for example a FreeDOS shell from a USB Drive.**
<div align="center">
<h2>Configuration files</h2>
</div>

**[/etc/network/interfaces](./interfaces)**

**[/etc/hosts](./hosts)**

**[/etc/update-motd.d/00-lab-motd](./motd/00-lab-motd)**
