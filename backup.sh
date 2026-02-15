#!/bin/bash

# Jenkins Backup Script
# This script creates a backup of Jenkins data volume

set -e  # Exit on error

# Configuration
BACKUP_DIR="./backups"
VOLUME_NAME="jenkins-data"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="jenkins-backup-${DATE}.tar.gz"
RETENTION_DAYS=30  # Keep backups for 30 days

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

log_info "Starting Jenkins backup..."

# Check if Jenkins container is running
if docker ps | grep -q jenkins; then
    log_info "Jenkins container is running. Stopping it gracefully..."
    docker-compose down
    RESTART_NEEDED=true
else
    log_info "Jenkins container is not running."
    RESTART_NEEDED=false
fi

# Create backup
log_info "Creating backup: ${BACKUP_FILE}"
docker run --rm \
    -v "${VOLUME_NAME}:/data" \
    -v "$(pwd)/${BACKUP_DIR}:/backup" \
    ubuntu tar czf "/backup/${BACKUP_FILE}" /data

# Check if backup was successful
if [ $? -eq 0 ]; then
    BACKUP_SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_FILE}" | cut -f1)
    log_info "Backup created successfully: ${BACKUP_FILE} (${BACKUP_SIZE})"
else
    log_error "Backup failed!"
    exit 1
fi

# Restart Jenkins if it was running
if [ "${RESTART_NEEDED}" = true ]; then
    log_info "Restarting Jenkins..."
    docker-compose up -d
fi

# Clean up old backups
log_info "Cleaning up backups older than ${RETENTION_DAYS} days..."
find "${BACKUP_DIR}" -name "jenkins-backup-*.tar.gz" -type f -mtime +${RETENTION_DAYS} -delete

# List remaining backups
BACKUP_COUNT=$(ls -1 "${BACKUP_DIR}"/jenkins-backup-*.tar.gz 2>/dev/null | wc -l)
log_info "Total backups: ${BACKUP_COUNT}"

log_info "Backup completed successfully!"

# Optional: Send notification (uncomment and configure)
# curl -X POST https://your-webhook-url.com/notify \
#     -H "Content-Type: application/json" \
#     -d "{\"text\": \"Jenkins backup completed: ${BACKUP_FILE}\"}"
