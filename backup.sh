#!/bin/bash


#######################################################################
# The directory to Backup
#######################################################################
BACKUP_DIR="./DATA"

#######################################################################
# The directory to Save the files in
#######################################################################
SAVE_DIR="./_BACKUP_"

#######################################################################
# credentials for the mysql
#######################################################################
MYSQLHOST="localhost"
MYSQLUSER="root"
MYSQLPASS="pass"

#######################################################################
# how long to keep the backups
#######################################################################
KEEP_FILES_FOR=$(( 60 * 24 * 30 )) # 30 days old

#######################################################################
# the log file
#######################################################################
LOG='./backup.log'

#######################################################################
# Get the current script path
#######################################################################

SCRIPT_FILE="$0"
SCRIPT_PATH=`dirname "$SCRIPT_FILE"`

#######################################################################

LIB="$SCRIPT_PATH/lib.sh"
if [ ! -f "$LIB" ]; then echo "The general lib is missing (Search: $LIB)"; exit; fi
. "$LIB"

# Backup all files
backupFiles $BACKUP_DIR $SAVE_DIR $LOG "clientname"

# Backup the data
backupDB $MYSQLHOST $MYSQLUSER $MYSQLPASS $SAVE_DIR/database $LOG "clientname-wp-old"

# delete old files
delExpiredFiles $SAVE_DIR/data $KEEP_FILES_FOR $LOG # 30 days old
delExpiredFiles $SAVE_DIR/database $KEEP_FILES_FOR $LOG # 30 days old
