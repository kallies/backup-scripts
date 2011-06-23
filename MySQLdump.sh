#!/bin/sh

################################################
# ~/git/backup-scripts/MySQLdump.sh
# Lukas Kallies
# Created: Do Jun 23, 2011 - Lukas Kallies
# Last modified: Do Jun 23, 2011 - 13:52
#
# This script backups all MySQL databases on a
# host. On debian based systems it greps for the
# debian-sys-maint password, otherwise you can
# configure user and password (e.g. root).
################################################

export LANG=C

ORG_DIR=`pwd`
MYSQLDUMP="/usr/bin/mysqldump"
GZIP="/bin/gzip"
GREP="/bin/grep"
SED="/bin/sed"

BACKUPPATH="/backup"
FILEPREFIX="mysqldump.all"
MYSQL_USER="debian-sys-maint"
MYSQL_PASS=`${GREP} -m 1 password /etc/mysql/debian.cnf | ${SED} -e 's/.*= *//'`

${MYSQLDUMP} --all-databases --password=${MYSQL_PASS} --user=${MYSQL_USER} --add-drop-table --add-locks --all --extended-insert --quick --lock-tables --allow-keywords > ${BACKUPPATH}/${FILEPREFIX}.sql
${GZIP} -f ${BACKUPPATH}/${FILEPREFIX}.sql

exit 0
