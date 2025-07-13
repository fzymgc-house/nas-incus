# dnscrypt-proxy

This role installs and configures dnscrypt-proxy for secure and private DNS resolution.

## Description

The `dnscrypt-proxy` role provides secure DNS resolution through:
- Encrypted DNS queries (DNS-over-HTTPS, DNS-over-TLS)
- DNS filtering and blocking capabilities
- Privacy protection against DNS surveillance
- Performance optimization with caching

## Requirements

- Ubuntu/Debian system
- Network connectivity for DNS resolution
- Sufficient system resources for DNS caching

## Role Variables

### Default Variables (`defaults/main.yml`)

The role uses default variables defined in the defaults directory for:
- Package installation requirements
- Service configuration parameters
- DNS resolver settings

### Configuration Templates

The role includes a comprehensive `dnscrypt-proxy.toml.j2` template that configures:
- Server selection and rotation
- DNS filtering rules
- Caching parameters
- Logging settings
- Security options

## Dependencies

None - this is a standalone DNS service role.

## Example Playbook

```yaml
- hosts: dns-servers
  become: true
  roles:
    - role: dnscrypt-proxy
```

## Features

### DNS Privacy
- **Encrypted Queries**: All DNS requests encrypted in transit
- **No Logging**: Prevents DNS query logging by ISPs
- **DNSSEC Support**: Cryptographic validation of DNS responses
- **Anonymized Relays**: Additional privacy layer through relay servers

### Performance
- **Caching**: Local DNS response caching for faster resolution
- **Load Balancing**: Automatic server selection and failover
- **IPv6 Support**: Dual-stack DNS resolution
- **Response Filtering**: Blocks malicious and unwanted domains

### Security
- **Malware Protection**: Blocks access to known malicious domains
- **Ad Blocking**: Optional advertising and tracking domain blocking
- **Custom Filters**: User-defined blocklists and allowlists
- **Fallback Resolvers**: Backup DNS servers for reliability

## Service Management

### systemd Integration
- **Service Unit**: Custom systemd service file
- **Automatic Startup**: Enabled for system boot
- **Health Monitoring**: Service status and restart capabilities
- **Logging**: Integration with system journal

### Configuration
- **Main Config**: `/etc/dnscrypt-proxy/dnscrypt-proxy.toml`
- **Service File**: `/etc/systemd/system/dnscrypt-proxy.service`
- **Cache Directory**: `/var/cache/dnscrypt-proxy/`

## DNS Server Selection

The proxy automatically selects from a curated list of DNS providers:
- **Cloudflare**: 1.1.1.1 with privacy focus
- **Quad9**: Security-focused DNS with malware blocking
- **OpenDNS**: Family-friendly filtering options
- **Custom Servers**: User-defined DNS-over-HTTPS endpoints

## Usage Notes

### Network Integration
- Typically configured as local DNS resolver (127.0.0.1:53)
- Integrates with systemd-resolved for system DNS
- Compatible with NetworkManager and systemd-networkd

### Performance Tuning
- Configurable cache size and TTL values
- Adjustable timeout and retry parameters
- Load balancing across multiple servers

## License

MIT

## Author Information

nas-incus project - fzymgc-house infrastructure automation