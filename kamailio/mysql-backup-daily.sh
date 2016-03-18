#!/bin/sh
#
# backup databases
# 27 apr 2009 - fred@teamforrest.com
#

DAY=`/bin/date +%a`
/usr/bin/mysqldump --all-databases --routines | gzip > /backups/`date +%Y%m%d`-mysqldump.sql.gz

