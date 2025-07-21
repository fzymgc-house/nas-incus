
resource "incus_profile" "default" {
  name        = "default"
  description = "Default TrueNAS profile"
  device {
    name = "eth0"
    type = "nic"
    properties = {
      network = "incusbr0"
    }
  }
  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = "default"
    }
  }
}

resource "incus_profile" "base" {
  name        = "base"
  description = "Base profile"

  config = {
    "boot.autostart"                       = true
    "linux.kernel_modules"                 = "br_netfilter"
    "security.nesting"                     = true
    "security.syscalls.intercept.mknod"    = true
    "security.syscalls.intercept.setxattr" = true
    "cloud-init.user-data"                 = file("${path.module}/base/cloud-init.user-data.yaml")
  }
}

resource "incus_profile" "github_runner" {
  name        = "github-runner"
  description = "GitHub Actions Runner profile"

  config = {
    "boot.autostart"                       = true
    "linux.kernel_modules"                 = "br_netfilter,overlay"
    "security.nesting"                     = true
    "security.syscalls.intercept.mknod"    = true
    "security.syscalls.intercept.setxattr" = true
    # "security.privileged"                  = false  # Required for Docker-in-Docker - BROKEN in TrunNAS currently
    "cloud-init.user-data"                 = file("${path.module}/github-runner/cloud-init.user-data.yaml")
  }
}

