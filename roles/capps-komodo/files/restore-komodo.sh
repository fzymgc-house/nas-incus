#!/bin/bash
# Komodo restore script
# This script restores PostgreSQL database and Komodo configuration from backup

set -euo pipefail

# Check if backup timestamp provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <backup_timestamp>"
    echo "Example: $0 20240721_143022"
    echo ""
    echo "Available backups:"
    ls -1 /mnt/backups/komodo/komodo_backup_*_manifest.txt 2>/dev/null | sed 's/.*komodo_backup_\(.*\)_manifest.txt/\1/' || echo "No backups found"
    exit 1
fi

BACKUP_TIMESTAMP=$1
BACKUP_DIR="/mnt/backups/komodo"
BACKUP_NAME="komodo_backup_${BACKUP_TIMESTAMP}"

# PostgreSQL connection details
PG_CONTAINER="komodo-postgres-1"
PG_USER="${POSTGRES_USER:-komodo}"
PG_DB="${POSTGRES_DB:-postgres}"

# Verify backup exists
if [ ! -f "${BACKUP_DIR}/${BACKUP_NAME}_manifest.txt" ]; then
    echo "Error: Backup ${BACKUP_NAME} not found!"
    exit 1
fi

echo "Restoring from backup: ${BACKUP_NAME}"
cat "${BACKUP_DIR}/${BACKUP_NAME}_manifest.txt"
echo ""
read -p "Are you sure you want to restore? This will overwrite current data! (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Restore cancelled."
    exit 0
fi

# 1. Stop Komodo services
echo "Stopping Komodo services..."
cd /mnt/stacks/komodo
docker-compose down

# 2. Restore PostgreSQL database
if [ -f "${BACKUP_DIR}/${BACKUP_NAME}_postgres.sql.gz" ]; then
    echo "Restoring PostgreSQL database..."
    # Start only postgres service
    docker-compose up -d postgres
    sleep 10  # Wait for postgres to be ready
    
    # Drop and recreate database
    docker exec "${PG_CONTAINER}" psql -U "${PG_USER}" -c "DROP DATABASE IF EXISTS ${PG_DB};"
    docker exec "${PG_CONTAINER}" psql -U "${PG_USER}" -c "CREATE DATABASE ${PG_DB};"
    
    # Restore data
    gunzip -c "${BACKUP_DIR}/${BACKUP_NAME}_postgres.sql.gz" | docker exec -i "${PG_CONTAINER}" psql -U "${PG_USER}" "${PG_DB}"
fi

# 3. Restore Komodo configuration
if [ -f "${BACKUP_DIR}/${BACKUP_NAME}_config.tar.gz" ]; then
    echo "Restoring Komodo configuration..."
    # Backup current config
    if [ -f "/mnt/data/komodo/config.toml" ]; then
        cp "/mnt/data/komodo/config.toml" "/mnt/data/komodo/config.toml.bak"
    fi
    # Extract backup
    tar -xzf "${BACKUP_DIR}/${BACKUP_NAME}_config.tar.gz" -C /mnt/data/komodo
fi

# 4. Restore FerretDB state
if [ -f "${BACKUP_DIR}/${BACKUP_NAME}_ferretdb.tar.gz" ]; then
    echo "Restoring FerretDB state..."
    # Backup current state
    if [ -d "/mnt/data/komodo/data/ferretdb" ]; then
        mv "/mnt/data/komodo/data/ferretdb" "/mnt/data/komodo/data/ferretdb.bak"
    fi
    # Extract backup
    tar -xzf "${BACKUP_DIR}/${BACKUP_NAME}_ferretdb.tar.gz" -C /mnt/data/komodo/data
fi

# 5. Start all services
echo "Starting all Komodo services..."
docker-compose up -d

echo "Restore completed successfully!"
echo "Please verify that all services are running correctly:"
echo "  docker-compose ps"