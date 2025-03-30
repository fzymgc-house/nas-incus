
data "incus_project" "default" {
  name = "default"
}

resource "incus_profile" "ares-server" {
  name = format("%s-profile", var.server_name)
  description = format("%s profile", var.server_name)

  device {
    name = "eth0"
    type = "nic"
    properties = {
      nictype = "macvlan"
      parent = "bond0"
      hwaddr = var.hwaddr
    }
  }

  device {
    name = "server"
    type = "disk"
    properties = {
      source = var.server_source_dir
      path = "/home/ares"
    }
  }

  device {
    name = "server_database"
    type = "disk"
    properties = {
      source = var.server_database_dir
      path = "/var/lib/valkey"
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

resource "incus_instance" "ares-server" {
  name = var.server_name
  description = var.server_description
  image = format("images:%s", var.server_image)
  profiles = ["default", incus_profile.ares-server.name]

  config = {
    "user.access_interface" = "eth0"
    "raw.idmap" = <<-EOT
      uid 568 568
      gid 568 568
    EOT
  }

  wait_for {
    type = "ipv4"
    nic = "eth0"
    delay = "30s"
  }
}
