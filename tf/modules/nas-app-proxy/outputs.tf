# Output values for the base module

output "instance_name" {
  description = "Name of the NAS App Proxy instance"
  value = incus_instance.nas-app-proxy.name
}

output "instance_ipv4_address" {
  description = "IP address of the NAS App Proxy instance"
  value = incus_instance.nas-app-proxy.ipv4_address
}

output "instance_ipv6_address" {
  description = "IPv6 address of the NAS App Proxy instance"
  value = incus_instance.nas-app-proxy.ipv6_address
}




