terraform {
  required_providers {
    proxmox = {
      source    = "telmate/proxmox"
      version   = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://10.10.20.201:8006/api2/json"
  pm_tls_insecure = true
}

resource "proxmox_lxc" "terraform_ct_test" {
  start         = "true"
  target_node   = "pve"
  hostname      = "terraform-test"
  password      = "terraform-test"

  ostemplate    = "local:vztmpl/centos-9-stream-default_20240828_amd64.tar.xz"
  
  rootfs {
    storage   = "vm-data"
    size      = "8G"
  }

  network {
    name    = "eth0"
    bridge  = "vmbr0"
    ip      = "10.10.40.20/24"
    gw      = "10.10.40.1"
    tag     = 40
  }
}
