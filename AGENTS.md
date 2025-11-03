# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a production infrastructure-as-code project for managing a NAS environment with containerized applications and
game servers. It combines **Terraform** for Incus (LXC) container provisioning, **Ansible** for configuration management,
and **Docker Compose** for application orchestration.

## Development Commands

### Terraform Operations

```bash
# Initialize Terraform (from tf/ directory)
cd tf && terraform init

# Plan infrastructure changes
terraform plan

# Apply infrastructure changes
terraform apply

# Format Terraform files
terraform fmt -recursive

# Validate Terraform configuration
terraform validate
```

**Important:** Terraform uses workspace `incus-nas` and Terraform Cloud backend (fzymgc-house/incus-nas).

### Ansible Operations

```bash
# Run the complete provisioning stack (Terraform + Ansible)
ansible-playbook main.yml

# Deploy container applications only
ansible-playbook nas-container-apps-playbook.yml

# Deploy AreMUSH game servers only
ansible-playbook ares-servers-playbook.yml

# Install required Ansible collections
ansible-galaxy install -r requirements.yml

# Test connectivity to all hosts
ansible all -m ping

# Run with specific tags
ansible-playbook main.yml --tags traefik,komodo

# Check what would change (dry run)
ansible-playbook main.yml --check --diff
```

**Ansible Configuration:**

- Inventory: `inventory/production.yml`
- Vault password: `.ansible_vault_password` (not in git)
- Host connection via Incus plugin for containers

### Pre-commit and Linting

```bash
# Install pre-commit hooks
pre-commit install

# Run all hooks on all files
pre-commit run --all-files

# Run specific hooks
pre-commit run terraform_fmt --all-files
pre-commit run ansible-lint --all-files
pre-commit run yamllint --all-files

# Run ansible-lint directly
ansible-lint

# Run yamllint directly
yamllint .

# Run shellcheck on scripts
shellcheck roles/*/files/*.sh
```

### Testing Individual Components

```bash
# Test a specific role
ansible-playbook -i inventory/production.yml --limit nas-container-apps roles/{role}/tests/test.yml

# Run Terraform plan for specific module
cd tf && terraform plan -target=module.nas-container-apps

# Validate a docker-compose file
docker compose -f roles/{role}/templates/compose.yaml.j2 config

# Test systemd-networkd configuration
networkctl status
```

## Architecture

### Infrastructure Layers

1. **Terraform (tf/)** - Provisions Incus containers and networks
   - `base` module: Creates default project, networks, storage pools
   - `profiles` module: Container profiles with base configurations
   - `nas-support` module: DHCP networking container
   - `nas-container-apps` module: Main application host (static IP, multiple disks)
   - `ares-server` module: Reusable game server instances

2. **Ansible (roles/)** - Configures containers and deploys applications
   - `common`: Network setup, SSH hardening, user management, auto-updates
   - `traefik`: Reverse proxy with Cloudflare DNS challenge
   - `capps-komodo`: Core application with PostgreSQL + FerretDB, backup/restore
   - `cloudflared-container`: Cloudflare tunnel daemon
   - `ares`: AreMUSH game server configuration

3. **Applications** - Deployed via Docker Compose
   - Komodo (core app) with PostgreSQL and FerretDB
   - Traefik (reverse proxy/API gateway)
   - Cloudflared (tunnel)
   - AreMUSH game servers (with Tailscale)

### Key Design Patterns

**Secrets Management:**

- All secrets retrieved via OnePassword lookups (vault: fzymgc-house)
- No hardcoded credentials in repository
- Use `community.general.onepassword` lookup plugin

```yaml
# Example OnePassword lookup
cloudflare_api_token: "{{ lookup('community.general.onepassword', 'cloudflare-api-token', field='password', vault='fzymgc-house') }}"
```

**User/Group Management:**

- Fixed UIDs across infrastructure for consistent permissions:
  - `568` - apps (service account)
  - `3500` - paperless
  - `3501` - immich
  - Standard users: fzymgc (admin), sean (support)

**Network Configuration:**

- Uses systemd-networkd for declarative networking
- Templates in `roles/common/templates/eth-*.network.j2`
- Static IP assignments via variables (e.g., nas-container-apps: 192.168.20.202/22)
- macvlan on bond0 for container networking

**Docker Deployment:**

1. Variables defined in `roles/{role}/vars/main.yml`
2. Compose file templated from `roles/{role}/templates/compose.yaml.j2`
3. Deploy via `community.docker.docker_compose_v2` module
4. Handlers trigger restarts on configuration changes

**Backup/Restore:**

- Komodo backups run daily via systemd timer (see `roles/capps-komodo/files/backup-komodo.sh`)
- Age encryption for backup security
- Restore script available at `roles/capps-komodo/files/restore-komodo.sh`

### Terraform Import Strategy

This project uses `import` blocks to manage existing Incus resources. When adding new infrastructure:

```hcl
# Import existing resources first
import {
  to = incus_instance.new_container
  id = "default/new_container"
}

# Then define the resource
resource "incus_instance" "new_container" {
  # ... configuration
}
```

### Adding a New Service

1. **Create Terraform module** (if new container needed):
   - Follow structure in `tf/modules/{service-name}/`
   - Define in `tf/main.tf`
   - Use `import` blocks for existing resources

2. **Write Ansible role**:

   ```
   roles/{service-name}/
   ├── defaults/main.yml      # Overridable defaults
   ├── vars/main.yml          # Role-specific variables
   ├── tasks/main.yml         # Task definitions
   ├── handlers/main.yml      # Service restart handlers
   ├── templates/             # Jinja2 templates (.j2)
   └── files/                 # Static files
   ```

3. **Use OnePassword for secrets** - never hardcode credentials

4. **Template docker-compose.yaml** from variables

5. **Run pre-commit** before committing

## Critical Configuration Variables

**Network Variables:**

- `network_eth0`, `network_eth1` - Network interface configurations
- `primary_domain` - Domain for FQDN resolution
- `host_data_base_dir` - Base path for application data

**Docker Variables:**

- `*_docker_network` - Docker network names (main-bridge, internal-bridge)
- `docker_compose_dir` - Location of compose files

**Application Variables:**

- Defined per-role in `roles/{role}/vars/main.yml`
- Use descriptive names: `{service}_{component}_{property}`

## Code Quality Standards

### Naming Conventions

- **Terraform resources**: snake_case (e.g., `incus_instance`)
- **Terraform modules**: kebab-case (e.g., `nas-container-apps`)
- **Ansible roles**: kebab-case (e.g., `capps-komodo`)
- **Ansible variables**: snake_case (e.g., `container_bridge_network_name`)
- **Ansible task names**: Use prefix pattern `"{role} | {description}"`

### Security Requirements

- Never commit secrets to version control
- Use `ansible-vault` for encrypted variables
- Set `no_log: true` for tasks with sensitive output
- Use principle of least privilege for user permissions
- Validate all input variables

### Task Best Practices

```yaml
# Always include error handling for commands
- name: "service | Execute command"
  ansible.builtin.command: some_command
  register: result
  changed_when: result.rc == 0
  failed_when: result.rc != 0
```

### Module Organization

- Each Terraform module must have: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`
- Each Ansible role should have: `tasks/main.yml`, `handlers/main.yml`, `defaults/main.yml`, `vars/main.yml`
- Use Jinja2 templates (`.j2`) for all configuration files

## Connection Details

**Incus Host:**

- Remote: `192.168.20.200:2443`
- Default project for containers
- Storage pools: default + apps

**Container Access:**

- Ansible connects via Incus plugin (see `ansible_connection: community.general.incus` in inventory)
- SSH available on all containers (fail2ban enabled)
- Primary admin user: fzymgc

**OnePassword Integration:**

- Vault: fzymgc-house
- Required for all secrets (API tokens, passwords, certificates)
- Use `community.general.onepassword` lookup

## Branch Strategy

**Main Branch:** `main`
**Current Branch:** `cq-updates` (interim, preparing for Portainer migration)

Use descriptive branch names for features and always create PRs for review.

## External Dependencies

**Ansible Collections** (install via `ansible-galaxy install -r requirements.yml`):

- `community.general` >=10.7.1 (OnePassword, Docker, Incus)
- `ansible.posix` (SSH key management)
- `artis3n.tailscale` (VPN integration)
- `geerlingguy.docker` (Docker installation)

**Cloud Services:**

- Terraform Cloud (fzymgc-house/incus-nas workspace)
- OnePassword (fzymgc-house vault)
- Cloudflare (DNS and SSL certificates)

## Troubleshooting

**Terraform state issues:**

```bash
cd tf
terraform state list
terraform state show <resource>
terraform refresh
```

**Ansible connection issues:**

```bash
# Test Incus connectivity
incus list --project default
incus exec nas-container-apps -- /bin/bash

# Test with ansible
ansible nas-container-apps -m ping -vvv
```

**Docker issues on containers:**

```bash
# SSH to container
incus exec nas-container-apps -- /bin/bash

# Check docker status
systemctl status docker
docker ps
docker compose -f /path/to/compose.yaml ps
```

**Network configuration issues:**

```bash
# Check systemd-networkd status
networkctl status
networkctl list

# View interface configuration
cat /etc/systemd/network/*.network

# Restart networking
systemctl restart systemd-networkd
```
