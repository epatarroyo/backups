#!/bin/sh

# First of all, make this script executable
# chmod +x backups.sh
#
# Then create a schedule to run the script every day and every month
# using crontab
# crontab -e

# 0 12 * * * /path/to/script/backups.sh >/dev/null 2>&1
# 30 12 1 * * /path/to/script/backups.sh >/dev/null 2>&1

# 0 12 * * * /path/to/script/backups.sh > backup.log
# 30 12 1 * * /path/to/script/backups.sh > backup.log

# MAILTO="info@email.com"
# 0 12 * * * /path/to/script/backups.sh
# MAILTO="info@email.com"
# 30 12 1 * * /path/to/script/backups.sh

### Libraries ###
MYSQLDUMP="$(which mysqldump)"
if [ -z "$MYSQLDUMP" ]; then
    echo "Error: MYSQLDUMP not found"
    exit 1
fi
GZIP="$(which gzip)"
if [ -z "$GZIP" ]; then
    echo "Error: GZIP not found"
    exit 1
fi

### vars ###
GNUPGPASSPHRASE="yourpassphrase123xyz"
BACKUPDIR="/path/to/files/"
GMAILUSERNAME="myname"
GMAILPASSWORD="mysecret"
GDRIVEPATH="google/drive/backup/path"
NOW="$(date +'%Y%m%d%H%M%S')"

###
# Database backup configuration
###
# If cleanup is set to "1", backups older than $OLDERTHAN days will be deleted!
CLEANUP=1
OLDERTHAN=30
HOST="$(hostname)"
MyHOST="locahost"  # Hostname
MyUSER="mydbuser"       # USERNAME
MyPASS="mysecretdbpassword"         # PASSWORD
MyDB="mydbname"  # Database
# Database Backup Dest directory
DESTMYSQL="/path/to/db/backup/directory"
STRUCTUREANDDATA="$DESTMYSQL/$NOW.$MyDB.full.$HOST.gz"
STRUCTUREONLY="$DESTMYSQL/$NOW.$MyDB.structure-only.$HOST.gz"
DATAONLY="$DESTMYSQL/$NOW.$MyDB.data-only.$HOST.gz"


# database
$MYSQLDUMP -u$MyUSER -p$MyPASS -h $MyHOST --single-transaction $MyDB | $GZIP -9 > $STRUCTUREANDDATA
$MYSQLDUMP -d -u$MyUSER -p$MyPASS -h $MyHOST --single-transaction $MyDB | $GZIP -9 > $STRUCTUREONLY
$MYSQLDUMP -t -u$MyUSER -p$MyPASS -h $MyHOST --single-transaction $MyDB | $GZIP -9 > $DATAONLY
# Remove files older than x days if cleanup is activated, only for daily folder
if [ $CLEANUP == 1 ]; then
    find $DESTMYSQL/ -name "*.gz" -type f -mtime +$OLDERTHAN -delete
fi


PASSPHRASE=$GNUPGPASSPHRASE duplicity $BACKUPDIR gdocs://$GMAILUSERNAME:$GMAILPASSWORD@gmail.com/$GDRIVEPATH/backup$NOW