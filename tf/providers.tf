provider "incus" {
  generate_client_certificates = true
  accept_remote_certificate = true

  remote {
    name = "nas"
    scheme = "https"
    address = "192.168.20.200"
    port = "3443"
    token = var.incus_token
    default = true
  }
}

provider "onepassword" {

}
