data "incus_storage_pool" "default" {
  name = var.storage_pool
}

data "incus_profile" "base" {
  name = "base"
}

data "incus_profile" "github_runner" {
  name = "github-runner"
}

resource "incus_instance" "github_runner" {
  count       = var.runner_count
  name        = var.runner_count > 1 ? "${var.runner_name}-${format("%02d", count.index + 1)}" : var.runner_name
  description = "GitHub Actions Runner ${count.index + 1}"
  image       = var.container_image
  profiles    = ["default", "base", "github-runner"]

  config = {
    "user.access_interface" = "eth1"
    "raw.idmap" = <<-EOT
      uid 568 568
      gid 568 568
    EOT
    "limits.cpu"    = var.cpu_cores
    "limits.memory" = var.memory_limit
  }

  # Internal network interface only for security
  device {
    name = "eth1"
    type = "nic"
    properties = {
      nictype = "bridged"
      parent  = var.container_bridge_network_name
    }
  }

  # Runner workspace storage
  device {
    name = "runner-workspace"
    type = "disk"
    properties = {
      path = "/home/runner/workspace"
      pool = data.incus_storage_pool.default.name
      size = var.disk_size
    }
  }

  wait_for {
    type  = "ipv4"
    nic   = "eth1"
    delay = "30s"
  }
}

resource "ansible_host" "github_runner" {
  count = var.runner_count
  name  = incus_instance.github_runner[count.index].name
  variables = {
    ansible_user = "fzymgc"
    ansible_host = incus_instance.github_runner[count.index].ipv4_address
  }
}