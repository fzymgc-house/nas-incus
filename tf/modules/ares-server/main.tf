
data "incus_project" "default" {
  name = "default"
}


resource "incus_instance" "ares-server" {
  name        = var.server_name
  description = var.server_description
  image       = format("images:%s", var.server_image)
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
      hwaddr  = var.hwaddr
    }
  }

  device {
    name = "server"
    type = "disk"
    properties = {
      source = var.server_source_dir
      path   = "/home/ares"
    }
  }

  device {
    name = "server_database"
    type = "disk"
    properties = {
      source = var.server_database_dir
      path   = "/var/lib/valkey"
    }
  }

  wait_for {
    type  = "ipv4"
    nic   = "eth0"
    delay = "30s"
  }
}
