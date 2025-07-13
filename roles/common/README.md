# common

This role provides essential system configuration and security hardening for all NAS infrastructure nodes.

## Description

The `common` role handles fundamental system setup including:
- Network configuration with systemd-networkd
- Essential package installation
- Security hardening with fail2ban and SSH configuration
- Mail relay setup via Postfix
- System updates and maintenance

## Requirements

- Ubuntu/Debian system
- Network connectivity for package installation
- Valid network configuration parameters
- Mail relay credentials (Mailgun)

## Role Variables

### Default Variables (`defaults/main.yml`)

```yaml
common_packages_to_install:
  - curl
  - debian-keyring
  - debian-archive-keyring
  - apt-transport-https
  - ca-certificates
  - fail2ban
  - neovim
  - ldnsutils
  - lsof
  - update-notifier-common

common_packages_to_install_for_mail:
  - postfix
  - mailutils
  - bsd-mailx
  - libsasl2-modules
  - ca-certificates
```

### Network Configuration

Network settings are provided via inventory variables:
- `network_eth0`: Primary network interface configuration
- `network_eth1`: Secondary network interface configuration (optional)

Example:
```yaml
network_eth0:
  ipv4_address: "192.168.1.100/24"
  ipv4_gateway: "192.168.1.1"
  dns_address: "1.1.1.1"
  use_dhcp_routes: "false"
```

### Mail Configuration

Mail relay settings from group vars:
- `mailgun_smtp_user`: SMTP username for mail relay
- `mailgun_smtp_password`: SMTP password for mail relay

## Dependencies

None - this is a foundational role that other roles depend on.

## Example Playbook

```yaml
- hosts: all
  become: true
  roles:
    - role: common
```

## Features

### Network Management
- **systemd-networkd**: Modern network configuration
- **Dual interface support**: Primary and secondary network interfaces
- **Static/DHCP configuration**: Flexible IP address assignment
- **IPv6 support**: Dual-stack networking capability

### Security Hardening
- **fail2ban**: Intrusion prevention system
- **SSH hardening**: Key-based authentication only
- **Automatic updates**: Security patch management
- **Firewall integration**: iptables/netfilter support

### Mail Services
- **Postfix relay**: Satellite mail configuration
- **Mailgun integration**: Reliable mail delivery
- **System notifications**: Automated alert delivery

### System Maintenance
- **Package management**: Essential tool installation
- **Service monitoring**: Health check capabilities
- **Log management**: Centralized logging setup

## Network Configuration Details

### Interface Templates
- `eth-static.network.j2`: Static IP configuration template
- `eth-dhcp.network.j2`: DHCP configuration template

### Supported Features
- Static IP assignment with custom routes
- DHCP with route override capabilities
- IPv6 privacy extensions
- Custom DNS server configuration
- Network namespace support

### Cloud-init Integration
- Removes conflicting cloud-init network configuration
- Ensures systemd-networkd takes precedence
- Handles smooth migration from cloud-init networking

## Mail Relay Configuration

### Postfix Setup
- Satellite system configuration
- SMTP authentication via SASL
- TLS encryption for mail transport
- Queue management and retry logic

### Mailgun Integration
- Authenticated SMTP relay
- Delivery tracking and analytics
- Bounce and complaint handling
- Rate limiting compliance

## License

MIT

## Author Information

nas-incus project - fzymgc-house infrastructure automation