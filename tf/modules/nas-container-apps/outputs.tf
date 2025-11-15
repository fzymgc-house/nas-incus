# Output values for the nas-container-apps module

output "instance_name" {
  description = "Name of the NAS Container Apps instance"
  value       = incus_instance.nas_container_apps.name
}

output "instance_ipv4_address" {
  description = "IP address of the NAS Container Apps instance"
  value       = incus_instance.nas_container_apps.ipv4_address
}

output "instance_ipv6_address" {
  description = "IPv6 address of the NAS Container Apps instance"
  value       = incus_instance.nas_container_apps.ipv6_address
}
