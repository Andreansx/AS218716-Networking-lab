variable "pm_api_url" {
  type = string
  default = "https://10.10.20.201:8006/api2/json"
}

variable "ct_hostname" {
  type = string
  default = "debian-lxc"
}

variable "ct_password" {
  type = string
  default = "debian_lxc"
}

variable "ct_memory" {
  type = number
  default = 8192
}

variable "ct_cores" {
  type = number
  default = 4
}

variable "ct_swap" {
  type = number
  default = 1024
}

variable "ct_storage" {
  type = string
  default = "vm-data"
}

variable "ct_size" {
  type = string
  default = "16G"
}

variable "ct_tag" {
  type = number
  default = 40
}
