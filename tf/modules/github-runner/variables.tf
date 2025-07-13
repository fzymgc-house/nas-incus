variable "runner_name" {
  description = "Name for the GitHub runner instance"
  type        = string
  default     = "runner"
}

variable "runner_count" {
  description = "Number of runner instances to create"
  type        = number
  default     = 1
  
  validation {
    condition     = var.runner_count > 0 && var.runner_count <= 10
    error_message = "Runner count must be between 1 and 10."
  }
}

variable "container_bridge_network_name" {
  description = "The name of the Incus bridge network to attach the container to"
  type        = string
}

variable "cpu_cores" {
  description = "Number of CPU cores to allocate to the runner"
  type        = string
  default     = "4"
  
  validation {
    condition     = can(regex("^[0-9]+$", var.cpu_cores)) && tonumber(var.cpu_cores) > 0 && tonumber(var.cpu_cores) <= 32
    error_message = "CPU cores must be a positive number between 1 and 32."
  }
}

variable "memory_limit" {
  description = "Memory limit for the runner container"
  type        = string
  default     = "8GiB"
  
  validation {
    condition     = can(regex("^[0-9]+(\.?[0-9]+)?(GiB|MiB)$", var.memory_limit))
    error_message = "Memory limit must be in format like '8GiB' or '512MiB'."
  }
}

variable "disk_size" {
  description = "Size of the disk for runner workspace"
  type        = string
  default     = "50GiB"
  
  validation {
    condition     = can(regex("^[0-9]+(\.?[0-9]+)?(GiB|MiB|TiB)$", var.disk_size))
    error_message = "Disk size must be in format like '50GiB', '100MiB', or '1TiB'."
  }
}

variable "storage_pool" {
  description = "Name of the Incus storage pool to use"
  type        = string
  default     = "incus-lvm-thinpool"
}

variable "container_image" {
  description = "Container image to use for the runner"
  type        = string
  default     = "images:ubuntu/oracular/cloud/20250712_07:42"
}