# Required provider versions

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    incus = {
      source  = "lxc/incus"
      version = ">= 0.3.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = ">=2.1.2"
    }
  }
}
