variable "pm_api_url" {
  type = string
  default = "https://10.10.20.201:8006/api2/json"
}

variable "ct_name" {
  type = string
  default = "debianLXC"
}

variable "ct_pass" {
  type = string
  default = "DebianLXC"
}

variable "storage" {
  type = string
  default = "vm-data"
}

variable "size" {
  type = string
  default = "8G"
}

variable "ip_address" {
  type = string
  default = "10.10.40.21/24"
}

variable "ip_gateway" {
  type = string
  default = "10.10.40.1"
}

variable "tag" {
  type = number
  default = "40"
}

variable "ct_ram" {
  type = number
  default = 2048
}

variable "ct_swap" {
  type = number
  default = 512
}

variable "ct_cores" {
  type = number
  default = 2
}
