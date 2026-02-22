#!/bin/bash

BACKUP_DIR="$HOME/RouterOS-backup"

CCR2004="border-leaf-ccr2004"

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")

RED="\e[1;31m"
BLU="\e[1;34m"
RES="\e[0m"

echo -e "\n\n   Starting$BLU $CCR2004 $RES config backup..\n\n"

CCR_BACKUP_FILE="${CCR2004}_backup_$TIMESTAMP"

echo -e "   Connecting to..$RED $CCR2004 $RES \n"

CCR_SSH_OUTPUT=$(ssh $CCR2004 "/export file=$CCR_BACKUP_FILE" 2>&1)

if [ $? -ne 0 ]; then
  {
    echo -e "\n$RED   Error: $RES $CCR_SSH_OUTPUT\n\n"
    exit 1
  }
else
  {
    echo -e "$BLU\n   Connected successfully ! $RES \n"
  }
fi

sleep 5

CCR_SCP_OUTPUT=$(scp $CCR2004:/$CCR_BACKUP_FILE.rsc "$BACKUP_DIR/" 2>&1)

if [ $? -ne 0 ]; then
  {
    echo -e "\n$RED Error:$RES $CCR_SCP_OUTPUT\n"
    echo -e "$RED   Finished with errors ^$RES\n"
  }
else
  {
    echo -e "\n   Backup from$RED $CCR2004$RES saved in $BACKUP_DIR as $BLU$CCR_BACKUP_FILE.rsc$RES\n\n"
    echo -e "$BLU   Finished with no errors$RES\n"
  }
fi

cat $BACKUP_DIR/$CCR_BACKUP_FILE.rsc >$HOME/Documents/networking-lab/border-leaf-ccr2004/config.rsc
