#!/bin/bash

#######################################################################
# Get the current script path
#######################################################################

SCRIPT_FILE="$0"
SCRIPT_PATH=`dirname "$SCRIPT_FILE"`

#######################################################################
# credentials for the mysql
#######################################################################
MYSQLHOST="${1:-'localhost'}"
MYSQLUSER="${2:-'root'}"
MYSQLPASS="${3:-''}"

#######################################################################
# The directory to Save the files in
#######################################################################
SAVE_DIR="${4:-$SCRIPT_PATH/DATA/database}"

#######################################################################
# how long to keep the backups
#######################################################################
KEEP_FILES_FOR=$(( 60 * 24 * 30 )) # 30 days

#######################################################################
# the log file
#######################################################################
LOG='./backup.log'

#######################################################################

LIB="$SCRIPT_PATH/lib-general.sh"
if [ ! -f "$LIB" ]; then echo "The general lib is missing (Search: $LIB)"; exit; fi
. "$LIB"

LIB="$SCRIPT_PATH/lib-mysql.sh"
if [ ! -f "$LIB" ]; then echo "The mysql lib is missing (Search: $LIB)"; exit; fi
. "$LIB"

# Backup the db
backupDB $MYSQLHOST $MYSQLUSER $MYSQLPASS $SAVE_DIR $LOG "database"

# delete old files
delExpiredFiles $SAVE_DIR/database $KEEP_FILES_FOR $LOG # 30 days old
