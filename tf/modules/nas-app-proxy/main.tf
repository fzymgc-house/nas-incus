
data "incus_project" "default" {
  name = "default"
}

resource "incus_instance" "nas-app-proxy" {
  name = "nas-app-proxy"
  description = "NAS App Proxy"
  image = "images:ubuntu/oracular/cloud"
  profiles = ["default", "base"]

  config = {
    "user.access_interface" = "eth0"
    "raw.idmap" = <<-EOT
      uid 568 568
      gid 568 568
    EOT
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      nictype = "macvlan"
      parent = "bond0"
      hwaddr = "00:16:3e:ae:aa:00"
    }
  }

  device {
    name = "eth1"
    type = "nic"
    properties = {
      parent = var.container_bridge_network_name
      nictype = "bridged"
      hwaddr = "00:16:3e:ae:ab:00"
    }
  }

  device {
    name = "data"
    type = "disk"
    properties = {
      source = "/mnt/main/fzymgc-house/incus/storage/nas-app-proxy/data"
      path = "/data"
    }
  }
  wait_for {
    type = "ipv4"
    nic = "eth0"
    delay = "30s"
  }
}
