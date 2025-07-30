#!/bin/bash
# Komodo backup script
# This script backs up PostgreSQL database and Komodo configuration

set -euo pipefail

# Configuration
BACKUP_DIR="/mnt/backups/komodo"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="komodo_backup_${TIMESTAMP}"
RETENTION_DAYS=7

# PostgreSQL connection details
PG_CONTAINER="komodo-postgres-1"
PG_USER="${POSTGRES_USER:-komodo}"
PG_DB="${POSTGRES_DB:-postgres}"

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

echo "Starting Komodo backup at ${TIMESTAMP}"

# 1. Backup PostgreSQL database
echo "Backing up PostgreSQL database..."
docker exec "${PG_CONTAINER}" pg_dump -U "${PG_USER}" "${PG_DB}" | gzip > "${BACKUP_DIR}/${BACKUP_NAME}_postgres.sql.gz"

# 2. Backup Komodo configuration
echo "Backing up Komodo configuration..."
tar -czf "${BACKUP_DIR}/${BACKUP_NAME}_config.tar.gz" \
    -C /mnt/data/komodo \
    config.toml \
    2>/dev/null || true

# 3. Backup FerretDB state (if exists)
echo "Backing up FerretDB state..."
if [ -d "/mnt/data/komodo/data/ferretdb" ]; then
    tar -czf "${BACKUP_DIR}/${BACKUP_NAME}_ferretdb.tar.gz" \
        -C /mnt/data/komodo/data \
        ferretdb
fi

# 4. Create backup manifest
cat > "${BACKUP_DIR}/${BACKUP_NAME}_manifest.txt" <<EOF
Komodo Backup Manifest
======================
Timestamp: ${TIMESTAMP}
Hostname: $(hostname)
Components backed up:
- PostgreSQL database: ${BACKUP_NAME}_postgres.sql.gz
- Komodo configuration: ${BACKUP_NAME}_config.tar.gz
- FerretDB state: ${BACKUP_NAME}_ferretdb.tar.gz

Backup location: ${BACKUP_DIR}
EOF

# 5. Clean up old backups
echo "Cleaning up backups older than ${RETENTION_DAYS} days..."
find "${BACKUP_DIR}" -name "komodo_backup_*" -type f -mtime +${RETENTION_DAYS} -delete

echo "Backup completed successfully!"
echo "Backup files:"
ls -lh "${BACKUP_DIR}/${BACKUP_NAME}"*

# Optionally sync to remote storage
# Example: rclone copy "${BACKUP_DIR}/${BACKUP_NAME}"* remote:backups/komodo/
