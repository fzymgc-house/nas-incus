provider "incus" {
  generate_client_certificates = true
  accept_remote_certificate    = true

  remote {
    name    = "nas"
    address = "https://192.168.20.200:2443"
    token   = var.incus_token
  }
}

provider "onepassword" {}

terraform {
  cloud {
    organization = "fzymgc-house"
    workspaces {
      name = "incus-nas"
    }
  }
}
