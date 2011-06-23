#!/bin/sh

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
