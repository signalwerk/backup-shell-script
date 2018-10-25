#!/bin/bash

if [ ! -n "$BASH" ] ;then echo Please run this script $0 with bash; exit 1; fi


#######################################################################
# backup mysql database to
#######################################################################
# 1. Argument = host
# 2. Argument = username
# 3. Argument = password
# 4. Argument = path to backup path
# 5. Argument = path to logfile (optional)
# 6. Argument = Name of the Backup (optional)

backupDB ()
{

  echo "$1"

  MYSQLHOST="${1:-'localhost'}"
  MYSQLUSER="${2:-'root'}"
  MYSQLPASS="${3:-''}"
  savePath=`dirname "${4:-'./BACKUP'}/noop"`
  LOG_PATH=${5:-'./report.log'}
  SETNAME=${6:-'BACKUP'}

  feed
  feed
  log "Backup database."
  line
  log "Parameters:"
  log "    MySQL Host:      $MYSQLHOST"
  log "    MySQL User:      $MYSQLUSER"
  log "    MySQL Password:  -- not loged --"
  log "    Save Path:       $savePath"
  log "    Log path:        $LOG_PATH"
  log "    Backup name:     $SETNAME"
  line

  # check for programms
  if which gzip >/dev/null; then
      log "    gzip (program) exists"
  else
      error "    gzip (program) missing"
  fi

  if which mysqldump >/dev/null; then
      log "    mysqldump (program) exists"
  else
      error "    mysqldump (program) missing"
  fi

  # check for the dir of the backup
  if [ ! -d "$savePath" ]; then mkdir -p "$savePath"; fi

  log "mysqldump start"

  mysqldump --opt -h$MYSQLHOST -u$MYSQLUSER  -p$MYSQLPASS --all-databases 2>> $LOG_PATH | gzip -9 > "$savePath/`NOWFS`-$SETNAME-db.sql.gz"

  log "mysqldump end"

  feed
  feed

}
