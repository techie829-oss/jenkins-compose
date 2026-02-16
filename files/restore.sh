#!/bin/bash

# Jenkins Restore Script
# This script restores Jenkins from a backup file

set -e  # Exit on error

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

# Configuration
BACKUP_DIR="./backups"
VOLUME_NAME="jenkins-data"

# Check if backup directory exists
if [ ! -d "${BACKUP_DIR}" ]; then
    log_error "Backup directory not found: ${BACKUP_DIR}"
    exit 1
fi

# List available backups
log_info "Available backups:"
ls -lh "${BACKUP_DIR}"/jenkins-backup-*.tar.gz 2>/dev/null | awk '{print NR". "$9" ("$5")"}'

# Check if any backups exist
BACKUP_COUNT=$(ls -1 "${BACKUP_DIR}"/jenkins-backup-*.tar.gz 2>/dev/null | wc -l)
if [ ${BACKUP_COUNT} -eq 0 ]; then
    log_error "No backups found in ${BACKUP_DIR}"
    exit 1
fi

# Ask user to select a backup
echo ""
read -p "Enter the number of the backup to restore (or path to backup file): " SELECTION

# Determine backup file
if [ -f "${SELECTION}" ]; then
    BACKUP_FILE="${SELECTION}"
elif [[ "${SELECTION}" =~ ^[0-9]+$ ]]; then
    BACKUP_FILE=$(ls -1 "${BACKUP_DIR}"/jenkins-backup-*.tar.gz 2>/dev/null | sed -n "${SELECTION}p")
    if [ -z "${BACKUP_FILE}" ]; then
        log_error "Invalid selection: ${SELECTION}"
        exit 1
    fi
else
    log_error "Invalid input: ${SELECTION}"
    exit 1
fi

log_info "Selected backup: ${BACKUP_FILE}"

# Confirm restoration
log_warn "This will REPLACE all current Jenkins data!"
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "${CONFIRM}" != "yes" ]; then
    log_info "Restore cancelled."
    exit 0
fi

# Stop Jenkins
log_info "Stopping Jenkins..."
docker compose down

# Remove old volume
log_info "Removing old Jenkins data volume..."
docker volume rm "${VOLUME_NAME}" 2>/dev/null || true

# Create new volume
log_info "Creating new Jenkins data volume..."
docker volume create "${VOLUME_NAME}"

# Restore backup
log_info "Restoring backup..."
docker run --rm \
    -v "${VOLUME_NAME}:/data" \
    -v "$(pwd)/$(dirname ${BACKUP_FILE}):/backup" \
    ubuntu tar xzf "/backup/$(basename ${BACKUP_FILE})" -C /

if [ $? -eq 0 ]; then
    log_info "Backup restored successfully!"
else
    log_error "Restore failed!"
    exit 1
fi

# Start Jenkins
log_info "Starting Jenkins..."
docker compose up -d

log_info "Restore completed successfully!"
log_info "Jenkins will be available shortly at http://localhost:8080"

# Wait for Jenkins to start
log_info "Waiting for Jenkins to start (this may take a minute)..."
sleep 10

# Check if Jenkins is running
if docker ps | grep -q jenkins; then
    log_info "Jenkins container is running."
    log_info "Check logs with: docker compose logs -f jenkins"
else
    log_error "Jenkins container is not running. Check logs for errors."
    exit 1
fi
