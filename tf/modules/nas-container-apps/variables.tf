# Input variables for the base module

variable "container_bridge_network_name" {
  description = "Name of the container bridge network"
  type        = string
}

variable "server_image" {
  description = "Name of the server image"
  type        = string
}
