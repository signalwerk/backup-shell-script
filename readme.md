# Backup Utility
Backup all the Databases for a given user and keeps the backup for 30 days.


## Setup for Database backup
- Copy `backup-mysql.sh` `lib-mysql.sh` `lib-general.sh` to the place you want your backups
- Create a folder called `DATA` next to those files
- Setup Cronjob

```
/usr/local/bin/bash /path/to/backup-mysql.sh $host $user $pw
```
