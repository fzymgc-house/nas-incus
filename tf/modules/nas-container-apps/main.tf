
data "incus_project" "default" {
  name = "default"
}

resource "incus_instance" "nas-container-apps" {
  name        = "nas-container-apps"
  description = "NAS Container Apps"
  image       = "images:ubuntu/oracular/cloud"
  profiles    = ["default", "base"]

  config = {
    "user.access_interface" = "eth0"
    "raw.idmap"             = <<-EOT
      uid 568 568
      gid 568 568
    EOT
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      nictype = "macvlan"
      parent  = "bond0"
      hwaddr  = "00:16:3e:ae:aa:01"
    }
  }

  device {
    name = "eth1"
    type = "nic"
    properties = {
      parent  = var.container_bridge_network_name
      nictype = "bridged"
      hwaddr  = "00:16:3e:ae:ab:01"
    }
  }

  device {
    name = "data"
    type = "disk"
    properties = {
      source = "/mnt/main/fzymgc-house/incus/storage/container-apps/data"
      path   = "/mnt/data"
    }
  }

  device {
    name = "stacks"
    type = "disk"
    properties = {
      source = "/mnt/main/fzymgc-house/incus/storage/container-apps/stacks"
      path   = "/mnt/stacks"
    }
  }

  wait_for {
    type  = "ipv4"
    nic   = "eth0"
    delay = "30s"
  }
}
