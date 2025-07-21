# Komodo Update Procedures

This document outlines the procedures for updating Komodo and its dependencies.

## Overview

Komodo consists of several components that may need updates:
- Komodo Core and Periphery (application containers)
- PostgreSQL database
- FerretDB MongoDB compatibility layer
- Configuration files

## Pre-Update Checklist

1. **Review Release Notes**
   - Check [Komodo releases](https://github.com/moghtech/komodo/releases)
   - Review breaking changes and migration requirements
   - Verify compatibility between components

2. **Create Backup**
   ```bash
   # Trigger manual backup before update
   systemctl start komodo-backup.service
   
   # Verify backup completed
   journalctl -u komodo-backup.service -n 20
   ```

3. **Check Current Versions**
   ```bash
   cd /mnt/stacks/komodo
   docker-compose ps
   docker-compose images
   ```

## Update Procedures

### 1. Update Komodo Core and Periphery

**Method A: Update to Latest Version**
```bash
# Navigate to Komodo directory
cd /mnt/stacks/komodo

# Pull latest images
docker-compose pull core periphery

# Restart services with new images
docker-compose up -d core periphery

# Verify services are healthy
docker-compose ps
```

**Method B: Update to Specific Version**
```bash
# Set specific version
export COMPOSE_KOMODO_IMAGE_TAG="v1.2.3"

# Pull and deploy
docker-compose pull core periphery
docker-compose up -d core periphery
```

### 2. Update PostgreSQL

**Warning**: Database updates require careful planning and testing.

```bash
# 1. Create full backup
/usr/local/bin/backup-komodo.sh

# 2. Stop all services
docker-compose down

# 3. Update compose file with new PostgreSQL version
# Edit /mnt/stacks/komodo/compose.yaml

# 4. Start only PostgreSQL
docker-compose up -d postgres

# 5. Verify database is accessible
docker exec komodo-postgres-1 pg_isready

# 6. Start remaining services
docker-compose up -d
```

### 3. Update FerretDB

```bash
# Similar process to PostgreSQL
docker-compose pull ferretdb
docker-compose up -d ferretdb
```

### 4. Configuration Updates

When Komodo introduces configuration changes:

1. **Backup current configuration**
   ```bash
   cp /mnt/data/komodo/config.toml /mnt/data/komodo/config.toml.bak
   ```

2. **Review configuration template**
   - Check the Ansible template: `roles/capps-komodo/templates/komodo-config.toml.j2`
   - Compare with [Komodo documentation](https://github.com/moghtech/komodo/blob/main/config/README.md)

3. **Apply configuration changes**
   ```bash
   # Re-run Ansible to update configuration
   ansible-playbook main.yml --tags capps-komodo --limit nas-container-apps
   ```

## Rolling Back Updates

If issues occur after an update:

### Quick Rollback (Previous Images Still Available)
```bash
# Stop services
docker-compose down

# Deploy previous version
export COMPOSE_KOMODO_IMAGE_TAG="v1.2.2"  # Previous version
docker-compose up -d

# Verify services
docker-compose ps
```

### Full Rollback (From Backup)
```bash
# Find recent backup
ls -la /mnt/backups/komodo/

# Restore from backup
/usr/local/bin/restore-komodo.sh 20240721_143022
```

## Post-Update Verification

1. **Check Service Health**
   ```bash
   # View container status
   docker-compose ps
   
   # Check health status
   docker inspect komodo-core-1 | jq '.[0].State.Health'
   
   # View logs
   docker-compose logs -f core
   ```

2. **Verify Functionality**
   - Access web UI: `https://komodo.fzymgc.house`
   - Test OIDC authentication
   - Verify existing deployments are visible
   - Test a simple deployment operation

3. **Monitor Logs**
   ```bash
   # Check for errors
   docker-compose logs --tail=100 core periphery | grep -i error
   
   # Monitor real-time logs
   docker-compose logs -f
   ```

## Troubleshooting

### Common Issues

1. **Services Won't Start**
   - Check logs: `docker-compose logs <service>`
   - Verify configuration is valid
   - Ensure database migrations completed

2. **Authentication Issues**
   - Verify OIDC configuration hasn't changed
   - Check Authentik provider settings
   - Review Komodo Core logs

3. **Database Connection Errors**
   - Verify PostgreSQL is running
   - Check database credentials in 1Password
   - Ensure network connectivity between containers

### Emergency Procedures

If the system is completely broken:

1. **Stop all services**
   ```bash
   docker-compose down
   ```

2. **Restore from last known good backup**
   ```bash
   /usr/local/bin/restore-komodo.sh <timestamp>
   ```

3. **Contact support or check issues**
   - [Komodo GitHub Issues](https://github.com/moghtech/komodo/issues)
   - Review logs for specific error messages

## Best Practices

1. **Test in Non-Production First**
   - If possible, test updates in a staging environment
   - Document any issues or configuration changes needed

2. **Schedule Maintenance Windows**
   - Plan updates during low-usage periods
   - Notify users of planned maintenance

3. **Keep Backups Current**
   - Ensure automated backups are running
   - Periodically test restore procedures
   - Consider off-site backup replication

4. **Monitor After Updates**
   - Watch logs for 24-48 hours after updates
   - Check backup job success
   - Verify all integrations still work

5. **Document Changes**
   - Record version changes in a changelog
   - Note any configuration modifications
   - Document any issues encountered

---
*Last Updated: 2025-07-21*