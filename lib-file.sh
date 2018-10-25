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
