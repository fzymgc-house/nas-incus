# Base module main configuration
# This module provides foundational infrastructure components

# Add your resource configurations here
# Example:
# resource "aws_vpc" "main" {
#   cidr_block = var.vpc_cidr
#   tags = var.tags
# }

resource "incus_project" "default" {
  name = "default"
  description = "Default Incus project"
  config = {
    "features.networks" = true
    "features.networks.zones" = true
  }
}

resource "incus_storage_pool" "default" {
  name = "default"
  description = "Default Incus storage pool"
  driver = "zfs"
  config = {
    source = "apps/.ix-virt"
    "zfs.pool_name" = "apps/.ix-virt"
  }
}

resource "incus_network" "incusbr0" {
  name = "incusbr0"
  type = "bridge"
  config = {
    "ipv4.address" = "10.55.208.1/24"
    "ipv4.nat" = "true"
    "ipv6.address" = "fd42:cc9f:263:e8b2::1/64"
    "ipv6.nat" = "true"
  }
}

resource "incus_network" "cbr0" {
  name = "cbr0"
  type = "bridge"
  description = "Container Apps Internal Bridge"
  config = {
    "ipv4.address" = "10.209.210.1/24"
    "ipv4.nat" = "false"
    "ipv4.routing" = "false"
    "ipv6.address" = "fd42:1b0c:1aa2:74e4::1/64"
    "ipv6.nat" = "false"
    "ipv6.routing" = "false"
  }
}

resource "incus_image" "ubuntu_oracular_cloud" {
  source_image = {
    remote = "images"
    name = "ubuntu/oracular/cloud"
    copy_aliases = true
  }
}

resource "incus_profile" "default" {
  name = "default"
  description = "Default TrueNAS profile"
  device {
    name = "eth0"
    type = "nic"
    properties = {
      network = incus_network.incusbr0.name
    }
  }
  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = incus_storage_pool.default.name
    }
  }
}
