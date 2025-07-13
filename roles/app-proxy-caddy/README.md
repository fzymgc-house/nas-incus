# app-proxy-caddy

This role configures Caddy as a reverse proxy for NAS applications, providing secure HTTPS access to internal services.

## Description

The `app-proxy-caddy` role sets up Caddy web server configurations to proxy requests to various NAS services including:
- Portainer (container management)
- Storj (decentralized storage)
- SearXNG (privacy-focused search engine)

It handles SSL certificate management through Cloudflare DNS challenges and ZeroSSL integration.

## Requirements

- Caddy web server must be installed (handled by the `caddy` role)
- Cloudflare API token for DNS challenges
- ZeroSSL EAB credentials for certificate issuance
- 1Password CLI for secrets management

## Role Variables

### Default Variables (`defaults/main.yml`)

```yaml
app_proxy_caddy_packages_to_install:
  - curl
  - debian-keyring
  - debian-archive-keyring
  - apt-transport-https
  - ca-certificates
```

### Template Variables (`vars/main.yml`)

- `searxng_site_additional_config`: Additional Caddy configuration for SearXNG including security headers and caching policies

### Required Secrets (from 1Password)

- `cloudflare-api-token`: API token for Cloudflare DNS challenges
- `zerossl-eab-creds`: ZeroSSL EAB credentials for certificate issuance

## Dependencies

This role depends on:
- `caddy` role for base Caddy installation

## Example Playbook

```yaml
- hosts: nas-app-proxy
  become: true
  roles:
    - role: caddy
    - role: app-proxy-caddy
```

## Configured Sites

The role configures the following sites:

- `nas-portainer.fzymgc.house` → `https://nas-container-apps.incus:9443`
- `nas-storj.fzymgc.house` → `http://192.168.20.200:20909`
- `nas-searxng.fzymgc.house` → `http://nas-container-apps.incus:8080`

## Security Features

- Automatic SSL certificate management
- Security headers (CSP, HSTS, X-Content-Type-Options)
- Rate limiting and access controls
- Cloudflare integration for DNS management

## License

MIT

## Author Information

nas-incus project - fzymgc-house infrastructure automation