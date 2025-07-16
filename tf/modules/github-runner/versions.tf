terraform {
  required_version = ">= 1.5.0"

  required_providers {
    incus = {
      source  = "lxc/incus"
      version = ">= 0.3.0"
    }
    ansible = {
      source  = "ansible/ansible"
      version = ">= 1.3.0"
    }
  }
}
