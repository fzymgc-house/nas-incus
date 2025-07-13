# ares

This role deploys and configures AreMUSH game servers, providing a complete text-based multiplayer game hosting environment.

## Description

The `ares` role handles the complete deployment of AreMUSH (A Redefined Engine for MU* Servers), including:
- Ruby environment setup with RVM
- AreMUSH core installation from Git repositories
- Web portal deployment
- Database configuration (Valkey/Redis)
- Web server integration (Caddy/HAProxy)
- Edge node configuration for external access

## Requirements

- Ubuntu/Debian system
- Sufficient disk space for game data
- Network connectivity for Git repository access
- Valid SSL certificates for HTTPS access

## Role Variables

### Default Variables (`defaults/main.yml`)

```yaml
ares_packages_to_install:
  - autoconf
  - automake
  - binutils
  - bison
  - build-essential
  - dialog
  - fish
  - git
  - nodejs
  - npm
  - python3
  - ruby-bundler
  - ruby-dev
  - unattended-upgrades
  - uuid
  - valkey
  - valkey-redis-compat

ruby_version: 3.1.2
```

### Environment Variables (`vars/main.yml`)

- `aresmush_git_url`: Git repository URL for AreMUSH core
- `aresmush_git_branch`: Git branch to deploy
- `areswebportal_git_url`: Git repository URL for web portal
- `areswebportal_git_branch`: Git branch for web portal

## Dependencies

None - this is a standalone role.

## Example Playbook

```yaml
- hosts: ares-servers
  become: true
  roles:
    - role: ares
      vars:
        game_host_name: "mygame"
        game_host_domain: "example.com"
```

## Game Server Features

### Core Components
- **AreMUSH Server**: Ruby-based MU* server engine
- **Web Portal**: Node.js web interface for character management
- **Database**: Valkey (Redis-compatible) for data persistence
- **Web Server**: Caddy for HTTPS termination and routing

### Networking
- **Internal Communication**: Direct TCP connections
- **External Access**: HTTPS via Caddy reverse proxy
- **Edge Node Integration**: HAProxy configuration for external routing

### Security
- **SSL/TLS**: Automatic certificate management
- **User Management**: Integrated authentication system
- **Access Controls**: Configurable permissions and roles

## File Structure

The role creates the following directory structure:
```
/home/ares/
├── aresmush/          # Core game server files
├── ares-webportal/    # Web interface files
└── .rvm/              # Ruby version manager
```

## Game Management

### Systemd Services
- `aresmush-<game_name>`: Game server daemon
- `valkey`: Database service

### Management Scripts
- `/home/ares/start-ares.sh`: Start game server
- `/home/ares/stop-ares.sh`: Stop game server

## License

MIT

## Author Information

nas-incus project - fzymgc-house infrastructure automation