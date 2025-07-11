# Output values for the base module

output "container_bridge_network_name" {
  description = "Name of the container bridge network"
  value       = incus_network.cbr0.name
}

