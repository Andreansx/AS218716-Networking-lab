#!/bin/bash

BACKUP_DIR="$HOME/RouterOS-backup"

TARGET="mikrotik-ccr"

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")

RED="\e[1;31m"
BLU="\e[1;34m"
RES="\e[0m"

echo -e "\n\n   Starting$BLU CCR2004$RES config backup..\n\n"

CCR_BACKUP_FILE="ccr_backup_$TIMESTAMP"

echo -e "   Connecting to..$RED $TARGET $RES \n"

SSH_OUTPUT=$(ssh $TARGET "/export file=$CCR_BACKUP_FILE" 2>&1)

if [ $? -ne 0 ]; then {   
    echo -e "\n$RED   Error: $RES $SSH_OUTPUT\n\n"
    exit 1
}
else {
    echo -e "$BLU\n   Connected successfully ! $RES \n"   
}
fi

sleep 5

SCP_OUTPUT=$(scp $TARGET:/$CCR_BACKUP_FILE.rsc "$BACKUP_DIR/" 2>&1)

if [ $? -ne 0 ]; then {
    echo -e "\n$RED Error:$RES $SCP_OUTPUT\n"
    echo -e "$RED   Finished with errors ^$RES\n"
}
else {
   echo -e "\n   Backup from CCR$RED $TARGET$RES saved in $BACKUP_DIR as $BLU$CCR_BACKUP_FILE.rsc$RES\n\n"
   echo -e "$BLU   Finished with no errors$RES\n"
}
fi

