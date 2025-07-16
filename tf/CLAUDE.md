# CLAUDE.md - Terraform Directory Guide

This file provides specific guidance for working with Terraform infrastructure code in this directory.

## Directory Structure

```
tf/
├── main.tf                 # Root module orchestrator
├── providers.tf           # Provider configurations
├── variables.tf           # Root-level variables
├── versions.tf            # Version constraints
├── terraform.tfvars       # Variable values (SECURITY WARNING: Contains token)
├── outputs.tf             # Root outputs (currently empty)
└── modules/
    ├── base/              # Core infrastructure (project, networks, storage)
    ├── profiles/          # Incus profiles and cloud-init configs
    ├── nas-app-proxy/     # Reverse proxy container
    ├── nas-support/       # Support services container
    ├── nas-container-apps/# Container application hosting
    ├── ares-server/       # Gaming server containers
    └── github-runner/     # GitHub Actions runners
```

## Module Dependency Order

1. **base** → Creates core infrastructure (networks, storage, project)
2. **profiles** → Defines container profiles with cloud-init
3. **container modules** → Deploy specific services using profiles

## Provider Configuration

### Active Providers
- **Incus**: Container infrastructure management
  - Remote: `192.168.20.200:2443`
  - Authentication: Token-based
  - Auto-generates client certificates
- **Terraform Cloud**: Remote state management
  - Organization: `fzymgc-house`
  - Workspace: `incus-nas`

### Available but Unused
- **1Password**: Configured for future secrets management

## Best Practices for This Project

### 1. Variable Management
```hcl
# DO: Use variables for values that change between environments
variable "container_count" {
  description = "Number of containers to create"
  type        = number
  default     = 1
}

# DON'T: Hardcode sensitive values
# NEVER commit tokens or passwords in terraform.tfvars
```

### 2. Resource Naming
- Use descriptive names: `nas-app-proxy`, not `proxy1`
- Include purpose in name: `github_runner_profile`
- Be consistent with hyphens vs underscores

### 3. Module Structure
Each module should have:
```
module-name/
├── main.tf       # Primary resources
├── variables.tf  # Input variables with descriptions
├── outputs.tf    # Exported values
├── versions.tf   # Provider version constraints
└── README.md     # Module documentation
```

### 4. Network Configuration
- External network: macvlan on `bond0`
- Internal network: bridge on `incusbr0` or `cbr0`
- MAC addresses: Use `format()` for proper hex generation

### 5. Cloud-init Best Practices
- Keep cloud-init files focused and minimal
- Use Ansible for complex configuration
- Always include package update in cloud-init
- Set proper file permissions for SSH keys

## Common Operations

### Adding a New Container Module
1. Create module directory: `modules/service-name/`
2. Copy structure from existing module
3. Update cloud-init profile if needed
4. Add module block to `main.tf`
5. Run `terraform init` to initialize module
6. Test with `terraform plan`

### Modifying Existing Infrastructure
```bash
# Always plan before applying
terraform plan -var-file=terraform.tfvars

# Apply specific module only
terraform apply -target=module.github-runners

# Destroy specific resource
terraform destroy -target=module.github-runners.incus_instance.github_runner[0]
```

### Import Existing Resources
```bash
# Import format for Incus instances
terraform import module.base.incus_network.incusbr0 incusbr0
```

## Security Guidelines

### CRITICAL: Fix Token Exposure
1. Remove `incus_token` from `terraform.tfvars`
2. Add to `.gitignore`: `terraform.tfvars`
3. Use environment variable: `export TF_VAR_incus_token="..."`
4. Or use 1Password provider for token retrieval

### Secrets Management Pattern
```hcl
# Use 1Password provider (already configured)
data "onepassword_item" "incus_token" {
  vault = "Infrastructure"
  uuid  = "incus-token-uuid"
}

# Reference in provider
provider "incus" {
  token = data.onepassword_item.incus_token.password
}
```

## Module Patterns

### Container Module Template
```hcl
# Standard container configuration
resource "incus_instance" "container_name" {
  name     = var.container_name
  image    = var.container_image
  profiles = ["default", "base", "specific-profile"]

  config = {
    "user.access_interface" = "eth0"
    "limits.cpu"           = var.cpu_limit
    "limits.memory"        = var.memory_limit
  }

  # Network configuration
  device {
    name = "eth0"
    type = "nic"
    properties = {
      nictype = "macvlan"
      parent  = "bond0"
      hwaddr  = format("00:16:3e:ae:%02x:%02x", var.mac_prefix, count.index)
    }
  }

  # Storage configuration
  device {
    name = "storage"
    type = "disk"
    properties = {
      source = var.storage_path
      path   = "/mnt/storage"
    }
  }
}
```

### Profile Module Pattern
```hcl
# Cloud-init profile configuration
resource "incus_profile" "profile_name" {
  name = var.profile_name

  config = {
    "cloud-init.user-data" = file("${path.module}/cloud-init.user-data.yaml")
  }

  # Inherit from base profile
  device {
    name = "root"
    type = "disk"
    properties = {
      pool = "default"
      path = "/"
    }
  }
}
```

## Troubleshooting

### Common Issues
1. **State Lock**: Someone else is running Terraform
   - Wait for other operation to complete
   - Or break lock if stale: `terraform force-unlock <lock-id>`

2. **Profile Not Found**: Module depends on profile that doesn't exist
   - Check module dependencies in `main.tf`
   - Ensure profiles module is applied first

3. **Network Conflicts**: MAC address or IP conflicts
   - Use dynamic MAC generation
   - Check for duplicate static IPs

### Debug Commands
```bash
# Verbose output
TF_LOG=DEBUG terraform plan

# Validate configuration
terraform validate

# Format check
terraform fmt -check -recursive

# Show current state
terraform state list
terraform state show module.base.incus_network.incusbr0
```

## Future Improvements

### High Priority
1. Remove token from terraform.tfvars
2. Add meaningful outputs to root module
3. Create terraform.tfvars.example template

### Medium Priority
1. Implement resource tagging strategy
2. Use more data sources instead of hardcoding
3. Add lifecycle rules for critical resources
4. Create generic container module to reduce duplication

### Low Priority
1. Add module versioning strategy
2. Create dependency diagram
3. Implement automated testing
4. Add pre-commit hooks for formatting

## Integration with Ansible

After Terraform creates infrastructure:
1. Ansible reads Terraform state (if needed)
2. Waits for cloud-init completion
3. Applies configuration management
4. Deploys applications

Key integration points:
- Container names must match Ansible inventory
- Network interfaces must align with Ansible expectations
- Cloud-init creates users that Ansible expects