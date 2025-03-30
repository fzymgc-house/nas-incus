# Output values for the base module

output "instance_name" {
  description = "Name of the NAS Support instance"
  value = incus_instance.nas-support.name
}

output "instance_ipv4_address" {
  description = "IP address of the NAS Support instance"
  value = incus_instance.nas-support.ipv4_address
}

output "instance_ipv6_address" {
  description = "IPv6 address of the NAS Support instance"
  value = incus_instance.nas-support.ipv6_address
}




