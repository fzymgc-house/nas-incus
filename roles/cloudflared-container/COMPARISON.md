# Cloudflared vs DNSCrypt-Proxy Container Comparison

This document compares the `cloudflared-container` role with the existing `dnscrypt-proxy-container` role.

## Key Differences

### Configuration Format

- **DNSCrypt-Proxy**: Uses TOML configuration format
- **Cloudflared**: Uses YAML configuration format (simpler and more readable)

### DNS Protocol

- **DNSCrypt-Proxy**: Supports DNSCrypt, DNS-over-HTTPS (DoH), and DNS-over-TLS (DoT)
- **Cloudflared**: Primarily DNS-over-HTTPS (DoH) with Cloudflare's infrastructure

### Server Selection

- **DNSCrypt-Proxy**: Wide variety of DNS providers and protocols
- **Cloudflared**: Optimized for Cloudflare's DNS servers (1.1.1.1, 1.0.0.1, etc.)

### Performance

- **DNSCrypt-Proxy**: Good performance with multiple upstream options
- **Cloudflared**: Optimized performance with Cloudflare's global network

### Security Features

- **DNSCrypt-Proxy**:
  - DNSCrypt protocol support
  - Anonymized DNS
  - Cloaking rules
  - Custom filtering
- **Cloudflared**:
  - Built-in Cloudflare security
  - Malware blocking (1.1.1.2)
  - Adult content blocking (1.1.1.3)
  - Family protection (1.1.1.3)

### Configuration Complexity

- **DNSCrypt-Proxy**: More complex configuration with many options
- **Cloudflared**: Simpler configuration focused on DoH

### Maintenance

- **DNSCrypt-Proxy**: Community-maintained Docker image
- **Cloudflared**: Official Cloudflare Docker image with regular updates

## Use Cases

### Choose DNSCrypt-Proxy when

- You need DNSCrypt protocol support
- You want maximum DNS provider flexibility
- You need advanced filtering and cloaking features
- You want to use non-Cloudflare DNS providers

### Choose Cloudflared when

- You want simple, secure DNS-over-HTTPS
- You prefer Cloudflare's infrastructure
- You want built-in malware/adult content blocking
- You need better integration with Cloudflare services
- You want simpler configuration and maintenance

## Performance Comparison

| Feature | DNSCrypt-Proxy | Cloudflared |
|---------|----------------|-------------|
| Protocol Support | DNSCrypt, DoH, DoT | Primarily DoH |
| Server Options | Many providers | Cloudflare optimized |
| Configuration | Complex TOML | Simple YAML |
| Maintenance | Community | Official |
| Security | Custom rules | Built-in Cloudflare |
| Performance | Good | Excellent (Cloudflare network) |

## Migration Guide

To migrate from DNSCrypt-Proxy to Cloudflared:

1. **Backup current configuration**
2. **Update playbook**: Replace `dnscrypt-proxy-container` with `cloudflared-container`
3. **Adjust variables**: Map DNSCrypt-Proxy variables to Cloudflared equivalents
4. **Test DNS resolution**: Ensure all queries work correctly
5. **Monitor performance**: Verify performance meets requirements

## Variable Mapping

| DNSCrypt-Proxy Variable | Cloudflared Variable |
|-------------------------|----------------------|
| `dnscrypt_proxy_server_names` | `cloudflared_proxy_dns_servers` |
| `dnscrypt_proxy_cache` | `cloudflared_cache` |
| `dnscrypt_proxy_log_level` | `cloudflared_log_level` |
| `dnscrypt_proxy_image` | `cloudflared_image` |

## Recommendations

- **For new deployments**: Consider Cloudflared for its simplicity and Cloudflare integration
- **For existing DNSCrypt-Proxy**: Evaluate if Cloudflared meets your specific requirements
- **For maximum flexibility**: Stick with DNSCrypt-Proxy
- **For Cloudflare ecosystem**: Use Cloudflared
