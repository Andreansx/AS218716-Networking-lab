# Local MikroTik RouterOS Wiki featuring Proxmox and Terraform

## This is a project that I wanted to automate the deployment of a self-hosted local mirror of the RouterOS Wiki. This IaC project will allow to create a really lightweight, unprivileged LXC container on Proxmox Virtual Environment server. For fetching the Wiki I will use `wget`

## This might be particularly useful for situations when Im doing a maintenance and something may break resulting in losing the access RouterOS Wiki.