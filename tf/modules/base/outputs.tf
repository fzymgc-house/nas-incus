# Output values for the base module

output "container_bridge_network_name" {
  description = "Name of the container bridge network"
  value       = incus_network.cbr0.name
}

output "container_default_profile_name" {
  description = "Name of the default container profile"
  value       = incus_profile.default.name
}

output "container_ubuntu_2504_image_name" {
  description = "Name of the 25.04 container image"
  value       = incus_image.ubuntu_2504_cloud.source_image.name
}

output "container_ubuntu_2404_image_name" {
  description = "Name of the 24.04 container image"
  value       = incus_image.ubuntu_2404_cloud.source_image.name
}

output "container_ubuntu_2510_image_name" {
  description = "Name of the 25.10 container image"
  value       = incus_image.ubuntu_2510_cloud.source_image.name
}
