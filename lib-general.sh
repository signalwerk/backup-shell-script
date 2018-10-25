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
