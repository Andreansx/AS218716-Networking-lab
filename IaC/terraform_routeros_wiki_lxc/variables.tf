variable "pm_api_url" {
  type = string
  default = "https://10.100.20.2:8006/api2/json"
}

variable "proxmox_node" {
  type = string
  default = "pve"
}

variable "lxc_password" {
  type = string
  sensitive = true
}

variable "lxc_template" {
  type = string
  default = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
}

