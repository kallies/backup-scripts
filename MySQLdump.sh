#!/bin/sh

################################################
# ~/git/backup-scripts/MySQLdump.sh
# Lukas Kallies
# Created: Do Jun 23, 2011 - Lukas Kallies
# Last modified: Die Nov 04, 2014 - 10:33
#
# This script backups all MySQL databases on a
# host. On debian based systems it greps for the
# debian-sys-maint password, otherwise you can
# configure user and password (e.g. root).
#
# Published under the MIT License (MIT)
################################################

export LANG=C
export PATH="/bin:/usr/bin"

ORG_DIR=`pwd`
MYSQLDUMP="mysqldump"
GZIP="gzip"
GREP="grep"
SED="sed"
CHMOD="chmod"

BACKUPPATH="/backup"
FILEPREFIX="mysqldump.all"
MYSQL_USER="debian-sys-maint"
MYSQL_PASS=`${GREP} -m 1 password /etc/mysql/debian.cnf | ${SED} -e 's/.*= *//'`

${MYSQLDUMP} --all-databases --password=${MYSQL_PASS} --user=${MYSQL_USER} --add-drop-table --add-locks --extended-insert --quick --lock-tables --allow-keywords --events > ${BACKUPPATH}/${FILEPREFIX}.sql
${GZIP} -f ${BACKUPPATH}/${FILEPREFIX}.sql
${CHMOD} o-rwx ${BACKUPPATH}/${FILEPREFIX}.sql.gz

exit 0
