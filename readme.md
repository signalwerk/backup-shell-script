# Backup Utility


## Setup for Database backup
Backup all the Databases for a given user and keeps the backup for 30 days.

- Copy `backup-mysql.sh` `lib-mysql.sh` `lib-general.sh` to the place you want your backups
- Create a folder called `DATA` next to those files
- Setup Cronjob (Example: `0 11,16,23 * * *`)

```bash
# $savepath = optional save-path

/usr/local/bin/bash /path/to/backup-mysql.sh $host $user $pw $savepath

# report nothing
/usr/local/bin/bash /path/to/backup-mysql.sh $host $user $pw $savepath >/dev/null 2>&1

# report only errors
/usr/local/bin/bash /path/to/backup-mysql.sh $host $user $pw $savepath > /dev/null
```
