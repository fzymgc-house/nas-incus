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

Backup Considerations
--------------------

Important data to backup:
- `/mnt/data/komodo/postgres/`: PostgreSQL database
- `/mnt/data/komodo/config/`: Komodo configuration
- `/mnt/stacks/komodo/komodo-config.toml`: Application configuration

Access
------

Once deployed, Komodo is accessible at:
- Web UI: `https://komodo.{{ primary_domain }}`
- Requires OIDC authentication through Authentik

License
-------

BSD

Author Information
------------------

Created for the fzymgc-house NAS infrastructure project.