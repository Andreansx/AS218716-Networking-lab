resource "proxmox_lxc" "routeros_wiki_lxc" {
  target_node = var.proxmox_node
  hostname = "routeros-wiki-local"
  password = var.lxc_password
  ostemplate = var.lxc_template

  features {
    nesting = true
  }
  start = true
  unprivileged = true

  cores = 2
  memory = 2048
  swap = 1024

  rootfs {
    storage = "vm-data"
    size = "16G"
  }

  network {
    ip = "dhcp"
    name = "eth0"
    bridge = "vmbr0"
    tag = 40
  }

}
