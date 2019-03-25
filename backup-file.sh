#!/bin/bash

#######################################################################
# Get the current script path
#######################################################################

SCRIPT_FILE="$0"
SCRIPT_PATH=`dirname "$SCRIPT_FILE"`

#######################################################################
# The directory to Backup
#######################################################################
BACKUP_DIR="$SCRIPT_PATH/data"

#######################################################################
# The directory to Save the files in
#######################################################################
SAVE_DIR="./_BACKUP_"

#######################################################################
# how long to keep the backups
#######################################################################
KEEP_FILES_FOR=$(( 60 * 24 * 30 )) # 30 days old

#######################################################################
# the log file
#######################################################################
LOG_PATH="$SCRIPT_PATH/backup.log"

#######################################################################

LIB="$SCRIPT_PATH/lib.sh"
if [ ! -f "$LIB" ]; then echo "The general lib is missing (Search: $LIB)"; exit; fi
. "$LIB"

# Backup all files
backupFiles $BACKUP_DIR $SAVE_DIR $LOG "clientname"

# delete old files
delExpiredFiles $SAVE_DIR $KEEP_FILES_FOR $LOG # 30 days old
