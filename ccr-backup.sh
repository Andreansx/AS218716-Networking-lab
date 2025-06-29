#!/bin/bash

CCR_IP="10.10.10.1"
CCR_USER="admin"

BACKUP_DIR="$HOME/RouterOS-backup"

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")

RED="\e[1;31m"
GRN="\e[1;32m"
RES="\e[0m"

echo -e "\n\n       Starting$GRN CCR2004$RES config backup..\n\n"

CCR_BACKUP_FILE="ccr_backup_$TIMESTAMP"

echo -e "   Connecting to..$RED $CCR_IP $RES \n\n"

ssh $CCR_USER@$CCR_IP "/export file=$CCR_BACKUP_FILE"
sleep 5
scp $CCR_USER@$CCR_IP:/$CCR_BACKUP_FILE.rsc "$BACKUP_DIR/"
echo -e "   Backup from CCR$RED $CCR_IP$RES saved in $BACKUP_DIR as $GRN$CCR_BACKUP_FILE.rsc$RES\n\n"

echo -e "   Finished..\n"
