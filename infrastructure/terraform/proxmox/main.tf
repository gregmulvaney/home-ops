terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://${var.pm_api_url}:8006/api2/json"
  pm_user         = "${var.pm_user}@pam"
  pm_password     = var.pm_pass
  pm_tls_insecure = true
}

resource "proxmox_lxc" "k3s_masters" {
  for_each        = var.master_nodes
  target_node     = var.target_node
  hostname        = each.key
  cores           = each.value["cores"]
  memory          = each.value["memory"]
  ostemplate      = var.template
  unprivileged    = false
  password        = "terraform"
  ssh_public_keys = file(var.ssh_public_keys)
  start           = true

  features {
    nesting = true
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "${each.value["ip"]}/24"
    gw     = var.gateway
  }

  rootfs {
    size    = each.value["disk"]
    storage = each.value["storage"]
  }

  connection {
    type        = "ssh"
    user        = "root"
    host        = each.value["ip"]
    private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "apt update",
      "apt upgrade -y",
    ]
  }
}

# Disable app armor on LXCs to allow virtualization
resource "null_resource" "disable_app_armor" {
  depends_on = [proxmox_lxc.k3s_masters]
  for_each   = var.master_nodes

  connection {
    type     = "ssh"
    host     = var.pm_api_url
    user     = var.pm_user
    password = var.pm_pass
  }

  provisioner "file" {
    destination = "/root/app_armor_${each.key}.sh"
    content = templatefile("./scripts/app_armor.sh", {
      "config_file" = "/etc/${proxmox_lxc.k3s_workers[each.key].id}.conf"
      "key"         = each.key
    })
  }

  provisioner "remote-exec" {

    inline = [
      "sh /root/app_armor_${each.key}.sh"
    ]
  }
}

resource "proxmox_lxc" "k3s_workers" {
  depends_on      = [proxmox_lxc.k3s_masters]
  for_each        = var.worker_nodes
  target_node     = var.target_node
  hostname        = each.key
  cores           = each.value["cores"]
  memory          = each.value["memory"]
  ostemplate      = var.template
  unprivileged    = false
  password        = "terraform"
  ssh_public_keys = file(var.ssh_public_keys)
  start           = true

  features {
    nesting = true
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "${each.value["ip"]}/24"
    gw     = var.gateway
  }

  rootfs {
    size    = each.value["disk"]
    storage = each.value["storage"]
  }

  connection {
    type        = "ssh"
    user        = "root"
    host        = each.value["ip"]
    private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "apt update",
      "apt upgrade -y",
    ]
  }
}


# Disable app armor on LXCs to allow virtualization
resource "null_resource" "disable_app_armor" {
  depends_on = [proxmox_lxc.k3s_workers]
  for_each   = var.worker_nodes

  connection {
    type     = "ssh"
    host     = var.pm_api_url
    user     = var.pm_user
    password = var.pm_pass
  }

  provisioner "file" {
    destination = "/root/app_armor_${each.key}.sh"
    content = templatefile("./scripts/app_armor.sh", {
      "config_file" = "/etc/${proxmox_lxc.k3s_workers[each.key].id}.conf"
    })
  }

  provisioner "remote-exec" {

    inline = [
      "sh /root/app_armor_${each.key}.sh"
    ]
  }
}

# Variables

variable "pm_api_url" {
  type = string
}

variable "pm_user" {
  type = string
}

variable "pm_pass" {
  type = string
}

variable "target_node" {
  type = string
}

variable "master_nodes" {
  type = map(any)
}

variable "worker_nodes" {
  type = map(any)
}

variable "template" {
  type = string
}

variable "ssh_public_keys" {
  type = string
}

variable "ssh_private_key" {
  type = string
}

variable "gateway" {
  type = string
}
