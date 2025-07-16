# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a comprehensive NAS (Network Attached Storage) infrastructure management project that combines Ansible automation with Terraform infrastructure provisioning. The system deploys and manages containerized applications on an Incus/LXC platform for home/small business use.

## Architecture

### Core Components
- **Incus Containers**: Lightweight Linux containers for service isolation
- **Terraform**: Infrastructure provisioning and lifecycle management
- **Ansible**: Configuration management and application deployment
- **Caddy**: Reverse proxy with automatic SSL certificate management
- **AreMUSH**: Text-based gaming server platform
- **Portainer**: Docker container management interface

### Network Architecture
- **Dual-network setup**: External (macvlan) and internal (bridge) networks
- **Tailscale VPN**: Secure remote access overlay network
- **DNS**: Custom domain (fzymgc.house) with dnscrypt-proxy for privacy
- **Security**: Fail2ban, SSH hardening, automated security updates

## Common Commands

### Infrastructure Provisioning
```bash
# Initialize and provision infrastructure
cd tf/
terraform init
terraform plan
terraform apply

# Deploy complete infrastructure
ansible-playbook main.yml

# Deploy specific components
ansible-playbook main.yml --tags nas-app-proxy
ansible-playbook main.yml --tags ares-servers
ansible-playbook main.yml --tags nas-support
ansible-playbook main.yml --tags nas-container-apps
```

### Development Workflow
```bash
# Install Ansible dependencies
ansible-galaxy install -r requirements.yml

# Test specific roles
ansible-playbook main.yml --tags common --check
ansible-playbook main.yml --limit nas-app-proxy --check

# Run with specific inventory
ansible-playbook -i inventory/production.yml main.yml
```

### Terraform Operations
```bash
# Working with Terraform workspace
cd tf/
terraform workspace select incus-nas
terraform plan -var-file=terraform.tfvars
terraform apply -auto-approve

# Destroy infrastructure (careful!)
terraform destroy
```

## Key Playbooks

### `main.yml`
Master orchestrator that:
1. Provisions Incus instances via Terraform
2. Bootstraps containers with cloud-init
3. Runs system updates and reboots
4. Orchestrates all service deployments

### Service-Specific Playbooks
- **`nas-app-proxy-playbook.yml`**: Caddy reverse proxy, dnscrypt-proxy, Tailscale
- **`nas-support-playbook.yml`**: Docker, administrative users, system tools
- **`nas-container-apps-playbook.yml`**: Portainer container management
- **`ares-servers-playbook.yml`**: AreMUSH gaming servers with Ruby/Valkey
- **`github-runners-playbook.yml`**: GitHub Actions self-hosted runners

## Terraform Infrastructure

### Quick Reference
- **Detailed Terraform Guide**: See `tf/CLAUDE.md` for comprehensive Terraform-specific documentation
- **Module Location**: `tf/modules/`
- **State Management**: Terraform Cloud workspace `incus-nas`

### Infrastructure Modules
- **`base/`**: Core Incus infrastructure (projects, networks, storage)
- **`profiles/`**: Cloud-init configuration and container profiles
- **`nas-app-proxy/`**: Reverse proxy container configuration
- **`nas-support/`**: Support services container
- **`nas-container-apps/`**: Container application hosting
- **`ares-server/`**: Gaming server containers
- **`github-runner/`**: GitHub Actions runner containers

### Critical Security Note
**WARNING**: The `terraform.tfvars` file currently contains exposed tokens. See `tf/CLAUDE.md` for remediation steps.

## Configuration Patterns

### Secrets Management
- Uses **1Password** for sensitive data retrieval
- Ansible vault for encrypted configuration
- No secrets in committed code

### Tagging Strategy
- All playbooks use consistent tags for selective execution
- Tags: `incus`, `terraform`, `nas-app-proxy`, `ares-servers`, `nas-support`, `nas-container-apps`, `github-runners`

### Dependencies
- Terraform provisions infrastructure first
- Ansible waits for cloud-init completion
- Service dependencies managed through task ordering

## Role Architecture

### `common/` Role
- Base system configuration (SSH, users, networking)
- Mail relay configuration with Postfix
- Fail2ban intrusion prevention
- systemd-networkd for network management

### `ares/` Role
- Ruby environment with RVM
- Valkey (Redis-compatible) database
- AreMUSH game server deployment
- Caddy/HAProxy integration for game networking

### `app-proxy-caddy/` Role
- Caddy web server configuration
- SSL certificate automation
- Reverse proxy rules for services

### `capps-portainer/` Role
- Portainer deployment for Docker management
- Container orchestration setup

### `github-runner/` Role
- GitHub Actions runner installation and configuration
- Supports organization and repository runners
- Automatic updates and custom labels
- Systemd service management

## Development Notes

### Ansible Configuration
- Uses `ansible.cfg` for consistent behavior
- Inventory in `inventory/` directory
- Host key checking disabled for containers
- SSH connection multiplexing enabled

### Terraform State Management
- Uses Terraform Cloud for remote state
- Workspace: `incus-nas`
- State includes sensitive infrastructure details

### Container Networking
- External network: `nas-external-network` (macvlan)
- Internal network: `nas-internal-network` (bridge)
- IPv4/IPv6 dual-stack support

## Security Considerations

- SSH key-based authentication only
- Automated security updates with scheduled reboots
- Network segmentation between services
- VPN-only access for external connectivity
- Secrets stored in 1Password, not in code

## Troubleshooting

### Common Issues
- **Cloud-init delays**: Playbooks wait for cloud-init completion
- **Package locks**: Extended timeout for initial container boot
- **Network connectivity**: Verify Incus network configuration
- **Terraform state**: Check workspace and provider connectivity

### Debug Commands
```bash
# Check container status
incus list

# View cloud-init logs
incus exec <container> -- cloud-init status --wait
incus exec <container> -- cat /var/log/cloud-init-output.log

# Ansible debug
ansible-playbook main.yml --check --diff --limit <host>
```

### Required paths
* On a mac ensure that the following paths are searched for commands:
  * /opt/homebrew/bin
  * /opt/homebrew/sbin

## Important Development Guidelines

### Terraform Development

**IMPORTANT**: For any Terraform changes, you MUST:
1. Review `tf/CLAUDE.md` for detailed Terraform guidelines and best practices
2. Run `terraform plan` before committing any changes
3. Never commit sensitive values in `terraform.tfvars`

Quick validation:
```bash
cd tf/
terraform validate
terraform plan
```

For detailed Terraform operations, module patterns, and troubleshooting, see `tf/CLAUDE.md`.

## Documentation Structure

### Documentation Organization
- **`/docs/`**: All project documentation
- **`/docs/changes/`**: Implementation plans and bug fix tracking
  - Update plans as phases complete
  - Track bug fixes and their resolution status
  - Document architectural decisions

### GitHub Runner Components
- **`github-runners-playbook.yml`**: Orchestrates GitHub runner deployment
- **`tf/modules/github-runner/`**: Terraform module for runner containers
- **`roles/github-runner/`**: Ansible role for runner configuration
- **Tags**: `github-runners` for selective deployment