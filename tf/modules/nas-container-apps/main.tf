
data "incus_project" "default" {
  name = "default"
}

resource "incus_profile" "nas-container-apps" {
  name = "nas-container-apps"
  description = "NAS Container Apps profile"

  device {
    name = "eth0"
    type = "nic"
    properties = {
      nictype = "macvlan"
      parent = "bond0"
      hwaddr = "00:16:3e:ae:aa:01"
    }
  }

  device {
    name = "eth1"
    type = "nic"
    properties = {
      parent = var.container_bridge_network_name
      nictype = "bridged"
      hwaddr = "00:16:3e:ae:ab:01"
    }
  }

  device {
    name = "data"
    type = "disk"
    properties = {
      source = "/mnt/main/fzymgc-house/incus/storage/container-apps/data"
      path = "/mnt/data"
    }
  }

  device {
    name = "stacks"
    type = "disk"
    properties = {
      source = "/mnt/main/fzymgc-house/incus/storage/container-apps/stacks"
      path = "/mnt/stacks"
    }
  }

  config = {
    "boot.autostart" = true
    "linux.kernel_modules" = "br_netfilter"
    "security.nesting" = true
    "security.syscalls.intercept.mknod" = true
    "security.syscalls.intercept.setxattr" = true
    "cloud-init.network-config" = file("${path.module}/cloud-init.network-config.yaml")
    "cloud-init.user-data" = file("${path.module}/cloud-init.user-data.yaml")
  }
}

resource "incus_instance" "nas-container-apps" {
  name = "nas-container-apps"
  description = "NAS Container Apps"
  image = "images:ubuntu/oracular/cloud"
  profiles = ["default", incus_profile.nas-container-apps.name]

  config = {
    "user.access_interface" = "eth0"
    "raw.idmap" = <<-EOT
      uid 568 568
      uid 3000 3000
      gid 568 568
      gid 4000 4000
      gid 3000 3000
    EOT
  }

  wait_for {
    type = "ipv4"
    nic = "eth0"
    delay = "30s"
  }
}
