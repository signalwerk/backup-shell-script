#!/bin/bash

if [ ! -n "$BASH" ] ;then echo Please run this script $0 with bash; exit 1; fi


LFTPsetup () {

  LFTP_excludes="${LFTP_excludes:-}"

  FTP_SERVER="${FTP_SERVER:-$PUBLICHOST}"
  FTP_USER="${FTP_USER:-$FTP_USER_NAME}"
  FTP_PASSWORD="${FTP_PASSWORD:-$FTP_USER_PASS}"

  FTP_SERVER="${FTP_SERVER:-ftp://}"
  FTP_USER="${FTP_USER:-anonymous}"
  FTP_PASSWORD="${FTP_PASSWORD:-password}"

  FTP_PARALLEL="${FTP_PARALLEL:-5}"

  FTP_INIT="${FTP_INIT:-}"
  FTP_INIT="$FTP_INIT set ftp:list-options -a;"
  FTP_INIT="$FTP_INIT set ftp:charset UTF-8;"
  FTP_INIT="$FTP_INIT set ssl:verify-certificate no;"
  FTP_INIT="$FTP_INIT set ftp:ssl-allow no;"

  log "FTP_SERVER: $FTP_SERVER"
  log "FTP_USER: $FTP_USER"
  log "FTP_PASSWORD: {FTP_PASSWORD}"
  log "FTP_INIT: $FTP_INIT"
  log "FTP_PARALLEL: $FTP_PARALLEL"
}

# mirror dry run and: --dry-run
getDir () {
  LFTPsetup
	mkdir -p $1
	lftp -u "${FTP_USER},${FTP_PASSWORD}" -e " \
	$FTP_INIT \
	lcd '$1'; \
	cd '$2'; \
	mirror --verbose=8 --parallel=${FTP_PARALLEL} --exclude-glob node_modules/ --exclude-glob .git/ $LFTP_excludes --delete; \
	quit; \
	" "${FTP_SERVER}"
}

pushDir () {
  LFTPsetup
	mkdir -p $1
	lftp -u "${FTP_USER},${FTP_PASSWORD}" -e " \
	$FTP_INIT \
	lcd '$1'; \
	cd '$2'; \
	mirror --reverse --verbose=8 --parallel=${FTP_PARALLEL} --exclude-glob node_modules/ --exclude-glob .git/ $FTP_excludes; \
	quit; \
	" "${FTP_SERVER}"
}
