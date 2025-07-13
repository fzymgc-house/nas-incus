variable "runner_name" {
  description = "Name for the GitHub runner instance"
  type        = string
  default     = "github-runner-01"
}

variable "runner_count" {
  description = "Number of runner instances to create"
  type        = number
  default     = 1
}

variable "container_bridge_network_name" {
  description = "The name of the Incus bridge network to attach the container to"
  type        = string
}

variable "cpu_cores" {
  description = "Number of CPU cores to allocate to the runner"
  type        = string
  default     = "4"
}

variable "memory_limit" {
  description = "Memory limit for the runner container"
  type        = string
  default     = "8GiB"
}

variable "disk_size" {
  description = "Size of the disk for runner workspace"
  type        = string
  default     = "50GiB"
}