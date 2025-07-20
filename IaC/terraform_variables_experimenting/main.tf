terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version   = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url = var.pm_api_url
  pm_tls_insecure = true
}

resource "proxmox_lxc" "terraform_debian_ct" {
  start = true
  unprivileged = true
  target_node = "pve"
  hostname = var.ct_name
  password = var.ct_pass

  ostemplate = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"

  rootfs {
    storage = var.storage
    size = var.size
  }

  network {
    name = "eth0"
    bridge = "vmbr0"
    ip = var.ip_address
    gw = var.ip_gateway
    tag = var.tag
  }
}
