terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url  = var.pm_api_url
  pm_tls_insecure = true
}

resource "proxmox_lxc" "debian-lxc" {
  
  target_node = "pve"

  hostname  = var.ct_hostname
  password  = var.ct_password
  memory    = var.ct_memory
  cores     = var.ct_cores
  swap      = var.ct_swap

  start         = true
  unprivileged  = true
  
  features {
    nesting = true
  }

  ostemplate = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"

  rootfs {
    storage = var.ct_storage
    size    = var.ct_size
  }
  
  network {
    name    = "eth0"
    bridge  = "vmbr0"
    ip      = "dhcp"
    tag     = var.ct_tag
  }
}
