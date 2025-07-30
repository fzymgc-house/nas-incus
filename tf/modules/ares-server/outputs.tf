# Output values for the base module

output "instance_name" {
  description = "Name of the Ares Server instance"
  value       = incus_instance.ares-server.name
}

output "instance_ipv4_address" {
  description = "IP address of the Ares Server instance"
  value       = incus_instance.ares-server.ipv4_address
}

output "instance_ipv6_address" {
  description = "IPv6 address of the Ares Server instance"
  value       = incus_instance.ares-server.ipv6_address
}
