
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
      uid 3000 3000
      uid 3500 3500
      gid 568 568
      gid 4000 4000
      gid 3000 3000
      gid 3500 3500
    EOT
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = "apps"
    }
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

  device {
    name = "paperless-data"
    type = "disk"
    properties = {
      source      = "/mnt/main/paperless-docs"
      path        = "/mnt/paperless-data"
      propagation = "rshared"
      recursive   = true
    }
  }

  wait_for {
    type  = "ipv4"
    nic   = "eth0"
    delay = "30s"
  }
}
