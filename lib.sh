#!/bin/bash

if [ ! -n "$BASH" ] ;then echo Please run this script $0 with bash; exit 1; fi


#######################################################################
#  Just an example to see how the restore should work
#  first restore the last full backup and then the incrementals
#######################################################################
# gnutar --extract --listed-incremental=_tar_snapshotfile.dat --file=files-full.tar.gz
# gnutar --extract --listed-incremental=_tar_snapshotfile.dat --file=files-incr.tar.gz
# gnutar --extract --listed-incremental=_tar_snapshotfile.dat --file=files-incr.tar.gz



#######################################################################
#  Helpers
#######################################################################


# now as Timestamp
NOW()
{
  echo `date "+%Y-%m-%d %H:%M:%S"`
}

# now as filesystem-compatible version
NOWFS()
{
  echo `date "+%Y-%m-%d--%H-%M"`
}

# Log a line with timestamp.
log()
{
  logUnstamped "[`NOW`]  LOG    $@"
}

# Log a error line with timestamp.
error()
{
  logUnstamped "[`NOW`]  ERROR  $@"
  feed
  feed
  exit 1
}

# Log without TS
logUnstamped()
{
  echo "$@"
  echo "$@"  >> ${LOG_PATH}
}

# line strong
feed()
{
  logUnstamped "#########################################################################################"
}
# line less strong
line()
{
  logUnstamped "-----------------------------------------------------------------------------------------"
}



#######################################################################
# delete old files in a directory
#######################################################################
# 1. Argument = path to delete the files in
# 2. Argument = minimal age to delete in minutes (optional – default is 30 days)
# 3. Argument = path to logfile (optional – default is ./report.log)
delExpiredFiles()
{

  delPath=`dirname "$1/noop"`
  expire_minutes=${2:-43200}  # default is 30 days
  LOG_PATH=${3:-'./report.log'}
  findConstructor="find ${delPath} -mindepth 1 -mmin +${expire_minutes} -name '*'"

  feed
  feed
  log "Delete expired files."
  line
  log "Parameters:"
  log "    Delete path: $delPath"
  log "    Minimal age: $expire_minutes minutes"
  log "    Log path:    $LOG_PATH"
  line

  # calculates the days
  if [ $expire_minutes -gt 1440 ]; then
      expire_days=$(( $expire_minutes /1440 ))
  else
      expire_days=0
  fi

  # check
  if [ ! -d "$delPath" ]; then error "The Path to delete the old files was not found. (Search: $delPath)"; fi


  # count deletes
  counter=0

  for del in $(eval $findConstructor)
  do
      counter=$(( counter + 1 ))
  done


  # delete process
  if [ $counter -lt 1 ]; then
      if [ $expire_days -gt 0 ]; then
          log "There were no files that were more than ${expire_days} days old."
      else
          log "There were no files that were more than ${expire_minutes} minutes old."
      fi
  else
      if [ $expire_days -gt 0 ]; then
          log "These files are more than ${expire_days} days old and they are being removed:"
      else
          log "These files are more than ${expire_minutes} minutes old and they are being removed:"
      fi

      counter=0
      for del in $(find $1 -name '*' -mindepth 1 -mmin +${expire_minutes})
      do
      counter=$(( counter + 1 ))
         log "    Expired file deleted: $del"
         rm -R $del
      done
  fi

  feed
  feed
}



#######################################################################
# backup files in a directory to a tar
#######################################################################
# 1. Argument = path to the files to backup
# 2. Argument = path to the save directory
# 3. Argument = path to logfile (optional)
# 4. Argument = Name of the Backup (optional)
#

backupFiles ()
{

  backupPath=`dirname "$1/noop"`
  savePath=`dirname "${2:-'./BACKUP'}/noop"`
  LOG_PATH=${3:-'./report.log'}
  SETNAME=${4:-'BACKUP'}

  feed
  feed
  log "Backup files."
  line
  log "Parameters:"
  log "    Backup path: $backupPath"
  log "    Save Path:   $savePath"
  log "    Log path:    $LOG_PATH"
  log "    Backup name: $SETNAME"
  line



  if [[ "$OSTYPE" == "linux-gnu" ]]; then
          TARP="$(which tar)"
          MD5="$(which md5sum)"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
          TARP="$(which gtar)"
          MD5="$(which md5)"
  elif [[ "$OSTYPE" == "freebsd"* ]]; then
          TARP="$(which gnutar)"
          MD5="$(which md5)"
  else
          TARP="$(which gnutar)"
          MD5="$(which md5)"
  fi


  # check for programms
  if which $MD5 >/dev/null; then
      log "    MD5 (program) exists"
  else
      error "    MD5 (program) missing"
  fi


  echo "$TARP"
  if which $TARP >/dev/null; then
      log "    tar (program) exists"
  else
      error "    tar (program) missing"
  fi

  # check
  if [ ! -d "$backupPath" ]; then error "The Path to delete the files was not found. (Search: $backupPath)"; fi

  # check for the dir of the backup
  if [ ! -d "$savePath/snapshotfile" ]; then mkdir -p "$savePath/snapshotfile"; fi
  if [ ! -d "$savePath/data" ]; then mkdir -p "$savePath/data"; fi

  INCFILE="$savePath/snapshotfile/_tar_snapshotfile.dat"


  #  Fullbackup at Sunday
  #  1=Mon, 2=Tue, 3=Wed, ...
  FULLBACKUP="7"
  DAY=$(date +"%u")

  log "tar start"

  # tar current stadium
  if [ ! -f $INCFILE ]; then
    log "Mode: initial"
    FILE="$SETNAME-`NOWFS`-files-full"
    $TARP -g "$INCFILE"  -zcvf "$savePath/data/$FILE.tar.gz" "$backupPath"
  elif [ "$DAY" = "$FULLBACKUP" ]; then
    log "Mode: full"
    FILE="$SETNAME-`NOWFS`-files-full"
    $TARP -zcvf "$savePath/data/$FILE.tar.gz" "$backupPath"
  else
    log "Mode: increment"
    FILE="$SETNAME-`NOWFS`-files-incr"
    $TARP -g "$INCFILE" -zcvf "$savePath/data/$FILE.tar.gz" "$backupPath"
  fi

  log "write md5"
  $MD5 "$savePath/data/$FILE.tar.gz" >"$savePath/data/$FILE.md5"
  log "tar end"
  line

  feed
  feed

}


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
