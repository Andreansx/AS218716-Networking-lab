#!/bin/bash

BACKUP_DIR="$HOME/RouterOS-backup"

CCR2004="core-ccr2004"
CRS326="core-crs326"

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")

RED="\e[1;31m"
BLU="\e[1;34m"
RES="\e[0m"

echo -e "\n\n   Starting$BLU Core-CCR2004 & Core-CRS326$RES config backup..\n\n"

CCR_BACKUP_FILE="core-ccr2004_backup_$TIMESTAMP"

echo -e "   Connecting to..$RED $CCR2004 $RES \n"

CCR_SSH_OUTPUT=$(ssh $CCR2004 "/export file=$CCR_BACKUP_FILE" 2>&1)

if [ $? -ne 0 ]; then {   
    echo -e "\n$RED   Error: $RES $CCR_SSH_OUTPUT\n\n"
    exit 1
}
else {
    echo -e "$BLU\n   Connected successfully ! $RES \n"   
}
fi

sleep 5

CCR_SCP_OUTPUT=$(scp $CCR2004:/$CCR_BACKUP_FILE.rsc "$BACKUP_DIR/" 2>&1)

if [ $? -ne 0 ]; then {
    echo -e "\n$RED Error:$RES $CCR_SCP_OUTPUT\n"
    echo -e "$RED   Finished with errors ^$RES\n"
}
else {
   echo -e "\n   Backup from$RED $CCR2004$RES saved in $BACKUP_DIR as $BLU$CCR_BACKUP_FILE.rsc$RES\n\n"
   echo -e "$BLU   Finished with no errors$RES\n"
}
fi
## CRS326 part

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")

CRS_BACKUP_FILE="core-crs326_backup_$TIMESTAMP"

echo -e "   Connecting to..$RED $CRS326 $RES \n"

CRS_SSH_OUTPUT=$(ssh $CRS326 "/export file=$CRS_BACKUP_FILE" 2>&1)

if [ $? -ne 0 ]; then {   
    echo -e "\n$RED   Error: $RES $SSH_OUTPUT\n\n"
    exit 1
}
else {
    echo -e "$BLU\n   Connected successfully ! $RES \n"   
}
fi

sleep 5

CRS_SCP_OUTPUT=$(scp $CRS326:/$CRS_BACKUP_FILE.rsc "$BACKUP_DIR/" 2>&1)

if [ $? -ne 0 ]; then {
    echo -e "\n$RED Error:$RES $CRS_SCP_OUTPUT\n"
    echo -e "$RED   Finished with errors ^$RES\n"
}
else {
   echo -e "\n   Backup from$RED $CRS326$RES saved in $BACKUP_DIR as $BLU$CRS_BACKUP_FILE.rsc$RES\n\n"
   echo -e "$BLU   Finished with no errors$RES\n"
}
fi
