#!/bin/sh
#
# backup databases
# github.com/fredposner
#

DAY=`/bin/date +%a`
/usr/bin/mysqldump -u root --opt --all-databases >/backups/backup-$DAY.sql

