#!/bin/bash
#
# Restore the latest backup of a Postgresql database.
#

BACKUP_DIR=/opt/sonarqube/backup
DATABASE=sonarqube
USER=sonar

# Find the latest backup file
latest_backup=$(ls -t "$BACKUP_DIR" | head -n 1)

# Check if backup directory is empty
if [ -z "$latest_backup" ]; then
    echo "No backup files found in $BACKUP_DIR"
    exit 1
fi

# Restore the latest backup
psql -U "$USER" -d "$DATABASE" < "$BACKUP_DIR/$latest_backup"