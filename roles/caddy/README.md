# caddy

This role installs and configures Caddy web server with automatic HTTPS and SSL certificate management.

## Description

The `caddy` role provides a complete Caddy web server installation including:
- Caddy installation from official Cloudsmith repositories
- xcaddy tool for building custom Caddy binaries
- Cloudflare DNS plugin integration
- SSL certificate automation with multiple CA support
- Custom binary management with alternatives system

## Requirements

- Ubuntu/Debian system with apt package manager
- Internet connectivity for package downloads
- Valid Cloudflare API token for DNS challenges
- 1Password CLI for secrets management

## Role Variables

### Default Variables (`defaults/main.yml`)

```yaml
caddy_packages_to_install:
  - curl
  - debian-keyring
  - debian-archive-keyring
  - apt-transport-https
  - ca-certificates

use_local_resolvers: false
```

### Certificate Authority Configuration

The role supports multiple ACME CAs, configured in `defaults/main.yml`:
- **Let's Encrypt Staging** (default): For testing
- **Let's Encrypt Production**: For production use
- **ZeroSSL**: Alternative CA with EAB support

## Dependencies

None - this is a base role for web server functionality.

## Example Playbook

```yaml
- hosts: web-servers
  become: true
  roles:
    - role: caddy
  vars:
    acme_ca: "https://acme-v02.api.letsencrypt.org/directory"  # Production
```

## Features

### Automatic HTTPS
- Automatic SSL certificate provisioning
- Certificate renewal automation
- Support for multiple ACME providers

### Custom Binary Support
- Built-in Cloudflare DNS plugin via xcaddy
- Alternative binary management
- Fallback to standard Caddy binary

### Repository Management
- Official Caddy stable repository
- xcaddy development tools repository
- GPG signature verification

## Binary Management

The role creates two Caddy binaries:
- `/usr/bin/caddy.default`: Standard Caddy binary
- `/usr/bin/caddy.custom`: Custom binary with Cloudflare plugin

The alternatives system prioritizes the custom binary (priority 50) over default (priority 10).

## SSL Configuration

### Supported Providers
- **Let's Encrypt**: Free SSL certificates
- **ZeroSSL**: Alternative free SSL provider
- **Custom CAs**: Any RFC 8555 compliant ACME provider

### DNS Challenge Support
- Cloudflare DNS API integration
- Automatic domain validation
- Wildcard certificate support

## File Locations

- **Configuration**: `/etc/caddy/Caddyfile`
- **Service**: `systemd` managed service
- **Logs**: Available via `journalctl -u caddy`

## License

MIT

## Author Information

nas-incus project - fzymgc-house infrastructure automation