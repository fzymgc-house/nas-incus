# Cloudflared Container Role

This Ansible role installs and configures Cloudflared using Docker Compose with the `cloudflare/cloudflared` image in proxy-dns mode.

## Features

- Installs Cloudflared using Docker Compose
- Uses the latest `cloudflare/cloudflared` image
- Configures proxy-dns mode for DNS-over-HTTPS (DoH)
- Sets up systemd service for automatic startup
- Creates necessary directories and user/group
- Uses command-line arguments for configuration (no config files needed)
- Supports both UDP and TCP DNS queries
- Includes optional metrics endpoint for monitoring
- Uses Cloudflare's 1.1.1.1 and 1.0.0.1 DNS servers

## Requirements

- Docker and Docker Compose (handled by geerlingguy.docker dependency)
- Port 53 available for DNS queries

## Role Variables

### Optional Variables

- `cloudflared_image`: Cloudflared Docker image (default: `cloudflare/cloudflared:latest`)
- `cloudflared_proxy_dns_servers`: List of DNS servers to use (default: Cloudflare's 1.1.1.1 and 1.0.0.1)
- `cloudflared_proxy_dns_port`: Port for DNS queries (default: `53`)
- `cloudflared_proxy_dns_address`: Address to bind to (default: `0.0.0.0`)
- `cloudflared_metrics_enabled`: Enable metrics (default: `true`)
- `cloudflared_metrics`: Metrics endpoint (default: `0.0.0.0:49312`)
- `cloudflared_proxy_dns_max_upstream_conns`: Max upstream connections (default: `5`)

## Directory Structure

```
/etc/cloudflared/
└── compose.yml             # Docker Compose file
```

## Usage

### Basic Usage

```yaml
- hosts: servers
  roles:
    - cloudflared-container
```

### With Custom Variables

```yaml
- hosts: servers
  vars:
    cloudflared_image: cloudflare/cloudflared:latest
    cloudflared_proxy_dns_servers:
      - "https://1.1.1.2/dns-query"  # Malware blocking
      - "https://1.0.0.2/dns-query"  # Malware blocking
    cloudflared_metrics_enabled: true
    cloudflared_proxy_dns_max_upstream_conns: 10
  roles:
    - cloudflared-container
```

## Configuration

### DNS Servers

The role configures Cloudflare's DNS servers by default:

- https://1.1.1.1/dns-query (Standard)
- https://1.0.0.1/dns-query (Standard)

Alternative servers available:

- https://1.1.1.2/dns-query (Malware blocking)
- https://1.0.0.2/dns-query (Malware blocking)
- https://1.1.1.3/dns-query (Adult content blocking)

### Features

- **DNS-over-HTTPS**: Secure DNS queries using HTTPS
- **Simple Configuration**: Uses command-line arguments (no config files)
- **Metrics**: Optional metrics endpoint for monitoring
- **Security**: Encrypted DNS queries
- **Fallback**: Multiple DNS servers for reliability
- **Performance**: Optimized for Cloudflare's global network

### Ports

- **UDP 53**: Standard DNS queries
- **TCP 53**: DNS queries over TCP
- **TCP 49312**: Metrics endpoint (optional)

## Tags

- `docker-cloudflared`: Only run Docker container tasks

## Dependencies

- `geerlingguy.docker`: Docker installation and configuration

## Example Playbook

```yaml
---
- name: Install Cloudflared
  hosts: dns_servers
  become: yes
  roles:
    - cloudflared-container
```

## Testing

Run the test playbook:

```bash
cd roles/cloudflared-container/tests
ansible-playbook -i inventory test.yml
```

## DNS Configuration

After installation, configure your system to use the Cloudflared proxy:

### Update /etc/resolv.conf

```bash
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf
```

### Or configure systemd-resolved

```bash
sudo systemd-resolve --set-dns=127.0.0.1 --interface=eth0
```

## Monitoring

Check the service status:

```bash
sudo systemctl status cloudflared
```

View logs:

```bash
sudo journalctl -u cloudflared -f
```

Test DNS resolution:

```bash
nslookup google.com 127.0.0.1
```

Check metrics (if enabled):

```bash
curl http://localhost:49312/metrics
```

## Advantages over DNSCrypt-Proxy

- **Simpler Configuration**: No config files needed, uses command-line arguments
- **Cloudflare Integration**: Native integration with Cloudflare's infrastructure
- **Better Performance**: Optimized for Cloudflare's global network
- **Automatic Updates**: Cloudflare maintains the official Docker image
- **Built-in Security**: Cloudflare's security features are built-in
- **Warp Integration**: Can be extended to use Cloudflare Warp for additional privacy

## Security Features

- **DNS-over-HTTPS**: All queries are encrypted
- **No Logging**: Cloudflare's 1.1.1.1 doesn't log queries
- **DNSSEC**: Automatic DNSSEC validation
- **Malware Blocking**: Optional malware blocking via Cloudflare's 1.1.1.2
- **Adult Content Blocking**: Optional adult content blocking via Cloudflare's 1.1.1.3
