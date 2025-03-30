# Input variables for the base module

variable "hwaddr" {
  description = "Hardware address for the container"
  type = string
}

variable "server_source_dir" {
  description = "Source directory for the server"
  type = string
}

variable "server_database_dir" {
  description = "Database directory for the server"
  type = string
}

variable "server_name" {
  description = "Name of the server"
  type = string
}

variable "server_description" {
  description = "Description of the server"
  type = string
  default = "Ares Server"
}

variable "server_image" {
  description = "Image of the server"
  type = string
  default = "ubuntu/oracular/cloud"
}
