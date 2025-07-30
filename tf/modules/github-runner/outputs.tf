output "instance_names" {
  description = "Names of the GitHub runner instances"
  value       = incus_instance.github_runner[*].name
}

output "instance_ipv4_addresses" {
  description = "IPv4 addresses of the GitHub runner instances"
  value       = incus_instance.github_runner[*].ipv4_address
}

output "instance_ipv6_addresses" {
  description = "IPv6 addresses of the GitHub runner instances"
  value       = incus_instance.github_runner[*].ipv6_address
}
