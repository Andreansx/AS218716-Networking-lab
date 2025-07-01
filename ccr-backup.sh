#!/bin/bash

BACKUP_DIR="$HOME/RouterOS-backup"

TARGET="mikrotik-ccr"

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")

RED="\e[1;31m"
GRN="\e[1;32m"
RES="\e[0m"

echo -e "\n\n       Starting$GRN CCR2004$RES config backup..\n\n"

CCR_BACKUP_FILE="ccr_backup_$TIMESTAMP"

echo -e "   Connecting to..$RED $TARGET $RES \n\n"

ssh $TARGET "/export file=$CCR_BACKUP_FILE"
sleep 5
scp $TARGET:/$CCR_BACKUP_FILE.rsc "$BACKUP_DIR/"
echo -e "\n\n   Backup from CCR$RED $TARGET$RES saved in $BACKUP_DIR as $GRN$CCR_BACKUP_FILE.rsc$RES\n\n"

echo -e "   Finished..\n"
