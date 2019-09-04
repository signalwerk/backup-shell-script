# Backup Utility


## Setup for Database backup
Backup all the Databases for a given user and keeps the backup for 30 days.

- Install `backup-mysql.sh` `lib-mysql.sh` `lib-general.sh` to the place you want your backups
- Create a folder called `DATA` next to those files
- Run Cronjob (Example: `0 11,16,23 * * *`)

### Install
```bash
curl https://raw.githubusercontent.com/signalwerk/backup-shell-script/master/backup-mysql.sh > backup-mysql.sh
curl https://raw.githubusercontent.com/signalwerk/backup-shell-script/master/lib-mysql.sh > lib-mysql.sh
curl https://raw.githubusercontent.com/signalwerk/backup-shell-script/master/lib-general.sh > lib-general.sh
```
### Run
Parameters
* `$host` = MySQL Uost (required)
* `$user` = MySQL User (required)
* `$pw` = MySQL Password (required)
* `$savepath` = save-path (optional)

```bash
/usr/local/bin/bash /path/to/backup-mysql.sh $host $user $pw $savepath

# report nothing
/usr/local/bin/bash /path/to/backup-mysql.sh $host $user $pw $savepath >/dev/null 2>&1

# report only errors
/usr/local/bin/bash /path/to/backup-mysql.sh $host $user $pw $savepath > /dev/null
```
