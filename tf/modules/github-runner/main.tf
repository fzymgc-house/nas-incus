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
    "user.access_interface" = "eth0"
    "raw.idmap"             = <<-EOT
      uid 568 568
      gid 568 568
    EOT
    "limits.cpu"            = var.cpu_cores
    "limits.memory"         = var.memory_limit
  }

  # External network interface for internet access
  device {
    name = "eth0"
    type = "nic"
    properties = {
      nictype = "macvlan"
      parent  = "bond0"
      hwaddr  = format("00:16:3e:ae:aa:%02x", count.index + 3)
    }
  }

  # Runner workspace will be created within the container's root filesystem

  wait_for {
    type  = "ipv4"
    nic   = "eth0"
    delay = "30s"
  }
}

resource "null_resource" "runner_wait_for_cloud_init" {
  count = var.runner_count

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for cloud-init to complete on ${incus_instance.github_runner[count.index].name}..."
      incus exec ${incus_instance.github_runner[count.index].name} -- cloud-init status --wait | grep -q 'done'
    EOT
  }

  depends_on = [incus_instance.github_runner]
}