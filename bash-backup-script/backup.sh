#!/bin/bash

# Load configuration from external file
CONFIG_FILE="/home/mrrobot/bash-backup-script/backup.conf"

if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  echo "Configuration file not found!"
  exit 1
fi

# Define variables
BACKUP_DATE=$(date +%Y%m%d%H%M%S)
BACKUP_FILENAME="backup_$BACKUP_DATE.tar.gz"
LOG_FILE="$BACKUP_DST/backup_$BACKUP_DATE.log"

# Make backup folder
mkdir -p "$BACKUP_DST/$BACKUP_DATE"

# Start logging
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting backup at $(date)"

# Run tar
tar -czf "$BACKUP_DST/$BACKUP_DATE/$BACKUP_FILENAME" -C "$BACKUP_SRC" .

# Verify success
if [ $? -eq 0 ]; then
  echo "Backup successful: $BACKUP_FILENAME"
  msmtp 231901058@rajalakshmi.edu.in < /home/mrrobot/bash-backup-script/success_email.txt
else
  echo "Backup failed"
  msmtp 231901058@rajalakshmi.edu.in < /home/mrrobot/bash-backup-script/failure_email.txt
  exit 1
fi

# Rotate backups
NUM_BACKUPS_TO_KEEP=5
cd "$BACKUP_DST"
ls -1dt backup_* | tail -n +$((NUM_BACKUPS_TO_KEEP + 1)) | xargs rm -rf

echo "Backup script completed successfully at $(date)"
exit 0
