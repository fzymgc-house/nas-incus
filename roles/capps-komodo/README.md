capps-komodo
============

Deploy and configure Komodo, a multi-server deployment and container management platform, on the NAS container apps infrastructure.

Requirements
------------

- Docker and Docker Compose plugin installed on the target host
- 1Password CLI configured for secret retrieval
- The `main-bridge` Docker network must exist
- CA certificates from the fzymgc PKI infrastructure
- Minimum 2GB RAM and 10GB disk space for PostgreSQL and application data

Role Variables
--------------

### Directory Configuration (vars/main.yml)
```yaml
capps_stacks_dir: "/mnt/stacks"          # Base directory for Docker stack files
capps_data_dir: "/mnt/data"              # Base directory for persistent data
capps_dir_owner: "apps"                  # Owner for all created directories
capps_dir_group: "apps"                  # Group for all created directories
capps_dir_mode: "0755"                   # Permissions for directories
```

### Komodo-specific Variables (defaults can be overridden)
```yaml
komodo_postgres_user: "komodo"           # PostgreSQL database user
komodo_postgres_db: "komodo"             # PostgreSQL database name
komodo_ferretdb_user: "komodo"           # FerretDB user
komodo_ferretdb_db: "komodo"             # FerretDB database
```

### External Variables Used
- `primary_domain`: The primary domain (e.g., "fzymgc.house")
- `komodo_authentik_*`: OIDC configuration from 1Password
- `komodo_passkey`: Application passkey from 1Password
- `komodo_webhook_secret`: Webhook secret from 1Password

Dependencies
------------

This role depends on:
- Docker being installed and configured (handled by `nas-support` role)
- Caddy reverse proxy configured with appropriate routes (handled by `app-proxy-caddy` role)
- The `main-bridge` Docker network existing

The role integrates with:
- **Authentik**: For OIDC authentication
- **Caddy**: As the reverse proxy (routes configured separately)
- **1Password**: For secure secret management

Example Playbook
----------------

```yaml
- hosts: nas-container-apps
  become: yes
  tasks:
    - name: Deploy Komodo container management platform
      include_role:
        name: capps-komodo
      tags:
        - komodo
        - container-apps
```

Architecture
------------

The role deploys a complete Komodo stack consisting of:

1. **PostgreSQL**: Primary database for Komodo Core
2. **FerretDB**: MongoDB-compatible layer over PostgreSQL for compatibility
3. **Komodo Core**: Main application server handling API and business logic
4. **Komodo Periphery**: Agent for executing deployments and managing containers

All services run in Docker containers with:
- Persistent data stored in `/mnt/data/komodo/`
- Configuration files in `/mnt/stacks/komodo/`
- Both internal (`main-bridge`) and external (`nas-external-network`) network connectivity

Security Features
-----------------

- OIDC authentication via Authentik (no local authentication)
- All secrets retrieved from 1Password at runtime
- TLS certificates for internal service communication
- Network isolation between services

### Docker Socket Access

**Important Security Consideration**: The Komodo Periphery container requires access to the Docker socket (`/var/run/docker.sock`) to manage containers on the host. This grants the container effectively root-level access to the host system.

**Mitigations in place**:
- Resource limits applied to the Periphery container (1 CPU, 1GB RAM)
- The container is labeled with `komodo.skip` to prevent self-termination
- Network isolation limits external access
- Only the Periphery container has Docker socket access (not Core)

**Recommendations**:
- Monitor Periphery container logs for suspicious activity
- Consider using Docker socket proxy solutions for additional isolation
- Regularly update Komodo images to get security patches
- Restrict access to the Komodo web UI through proper OIDC configuration

Backup Strategy
---------------

### Automated Backups

This role configures automated daily backups with:
- **Schedule**: Daily with randomized delay (0-1 hour)
- **Retention**: 7 days of backups
- **Location**: `/mnt/backups/komodo/`

### Backup Components

1. **PostgreSQL Database**: Full database dump (compressed)
2. **Komodo Configuration**: Application configuration files
3. **FerretDB State**: MongoDB-compatible data (if present)
4. **Backup Manifest**: Metadata about each backup

### Manual Backup/Restore

```bash
# Create manual backup
/usr/local/bin/backup-komodo.sh

# List available backups
ls -la /mnt/backups/komodo/

# Restore from backup (requires timestamp)
/usr/local/bin/restore-komodo.sh 20240721_143022
```

### Monitoring Backups

```bash
# Check backup timer status
systemctl status komodo-backup.timer

# View recent backup logs
journalctl -u komodo-backup.service -n 50

# Manually trigger backup
systemctl start komodo-backup.service
```

### Important Notes

- Backups are stored locally by default
- Consider configuring remote backup sync (e.g., rclone) for offsite copies
- Test restore procedures regularly
- Monitor backup disk usage

Access
------

Once deployed, Komodo is accessible at:
- Web UI: `https://komodo.{{ primary_domain }}`
- Requires OIDC authentication through Authentik

Update Procedures
-----------------

For detailed update and upgrade procedures, see `/docs/komodo-update-procedures.md`.

Quick update to latest version:
```bash
cd /mnt/stacks/komodo
docker-compose pull
docker-compose up -d
```

Always create a backup before updating:
```bash
systemctl start komodo-backup.service
```

License
-------

BSD

Author Information
------------------

Created for the fzymgc-house NAS infrastructure project.