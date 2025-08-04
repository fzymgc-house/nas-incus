# Traefik Role

This Ansible role installs and configures Traefik reverse proxy using Docker Compose.

## Features

- Installs Traefik v3.0 using Docker Compose
- Configures automatic SSL certificate generation using Cloudflare DNS challenge
- Sets up systemd service for automatic startup
- Creates necessary directories and user/group
- Configures logging and access logs
- Provides dashboard access with basic authentication

## Requirements

- Docker and Docker Compose (handled by geerlingguy.docker dependency)
- OnePassword CLI for secret management
- Cloudflare API token for DNS challenge

## Role Variables

### Required Variables

- `cloudflare_api_token`: Cloudflare API token for DNS challenge
- `zerossl_key_id`: ZeroSSL EAB credentials username
- `zerossl_mac_key`: ZeroSSL EAB credentials password

### Optional Variables

- `traefik_image`: Traefik Docker image (default: `traefik:v3.0`)
- `traefik_acme_email`: Email for ACME certificate notifications
- `traefik_api_dashboard`: Enable Traefik dashboard (default: `true`)
- `traefik_api_insecure`: Allow insecure API access (default: `false`)
- `traefik_api_debug`: Enable debug mode (default: `false`)

## Directory Structure

```
/etc/traefik/
├── traefik.yml          # Main configuration
├── compose.yml          # Docker Compose file
├── dynamic/            # Dynamic configuration files
├── certificates/       # SSL certificates
└── data/              # Persistent data
```

## Usage

### Basic Usage

```yaml
- hosts: servers
  roles:
    - traefik
```

### With Custom Variables

```yaml
- hosts: servers
  vars:
    traefik_image: traefik:v3.0
    traefik_acme_email: admin@example.com
  roles:
    - traefik
```

## Configuration

### Entry Points

The role configures two entry points:

- `web`: HTTP on port 80 (redirects to HTTPS)
- `websecure`: HTTPS on port 443

### Providers

- **Docker**: Auto-discovers containers with Traefik labels
- **File**: Watches `/etc/traefik/dynamic` for configuration files

### Certificate Resolver

Uses Cloudflare DNS challenge for automatic SSL certificate generation.

## Dashboard Access

The Traefik dashboard is available at `https://traefik.yourdomain.com` with basic authentication.

## Tags

- `docker-traefik`: Only run Docker container tasks

## Dependencies

- `geerlingguy.docker`: Docker installation and configuration

## Example Playbook

```yaml
---
- name: Install Traefik
  hosts: proxy_servers
  become: yes
  roles:
    - traefik
```

## Testing

Run the test playbook:

```bash
cd roles/traefik/tests
ansible-playbook -i inventory test.yml
```
