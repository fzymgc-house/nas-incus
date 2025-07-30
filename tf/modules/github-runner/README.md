# GitHub Runner Terraform Module

This module creates Incus containers configured as GitHub Actions self-hosted runners.

## Features

- Creates one or more GitHub Actions runner containers
- Configurable CPU, memory, and storage resources
- Security-focused with internal network isolation
- Support for multiple runner instances
- Automatic Ansible inventory integration

## Usage

### Basic Usage

```hcl
module "github-runners" {
  source                        = "./modules/github-runner"
  container_bridge_network_name = "nas-internal-network"
}
```

### Advanced Usage

```hcl
module "github-runners" {
  source                        = "./modules/github-runner"
  container_bridge_network_name = "nas-internal-network"

  # Create 3 runner instances
  runner_count = 3
  runner_name  = "ci-runner"

  # Customize resources
  cpu_cores    = "8"
  memory_limit = "16GiB"
  disk_size    = "100GiB"

  # Use custom storage pool
  storage_pool = "fast-nvme-pool"

  # Pin specific image version
  container_image = "images:ubuntu/oracular/cloud/20250712_07:42"
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `container_bridge_network_name` | The name of the Incus bridge network | `string` | n/a | yes |
| `runner_name` | Base name for runner instances | `string` | `"runner"` | no |
| `runner_count` | Number of runner instances (1-10) | `number` | `1` | no |
| `cpu_cores` | CPU cores per runner (1-32) | `string` | `"4"` | no |
| `memory_limit` | Memory limit per runner | `string` | `"8GiB"` | no |
| `disk_size` | Workspace disk size | `string` | `"50GiB"` | no |
| `storage_pool` | Incus storage pool name | `string` | `"incus-lvm-thinpool"` | no |
| `container_image` | Container image to use | `string` | `"images:ubuntu/oracular/cloud/20250712_07:42"` | no |

## Outputs

| Name | Description |
|------|-------------|
| `instance_names` | Names of created runner instances |
| `instance_ipv4_addresses` | IPv4 addresses of runner instances |
| `instance_ipv6_addresses` | IPv6 addresses of runner instances |

## Resource Naming

- Single instance: Uses `runner_name` directly
- Multiple instances: `${runner_name}-01`, `${runner_name}-02`, etc.

## Security Considerations

This module implements several security best practices:

1. **Network Isolation**: Runners are connected only to the internal bridge network
2. **No External Access**: No macvlan/external network interface
3. **User Mapping**: Configured with standard apps user (UID/GID 568)
4. **Resource Limits**: Enforced CPU and memory constraints

## Prerequisites

- Incus must be installed and configured
- The specified bridge network must exist
- The base and github-runner profiles must exist (created by profiles module)
- Storage pool must exist and have sufficient space

## Integration with GitHub

After the containers are created, you'll need to:

1. Install the GitHub Actions runner software (handled by Ansible role)
2. Register runners with your GitHub organization/repository
3. Configure runner labels and capabilities
4. Set up authentication tokens

See the Ansible `github-runner` role for automated setup.

## Troubleshooting

### Container fails to start

- Check if the storage pool exists: `incus storage list`
- Verify the base profile exists: `incus profile list`
- Ensure sufficient resources on the host

### Network connectivity issues

- Verify bridge network exists: `incus network list`
- Check container network configuration: `incus config device show <container-name>`

### Resource allocation errors

- Check available host resources before increasing limits
- Ensure CPU cores don't exceed host capacity
- Verify storage pool has sufficient free space
