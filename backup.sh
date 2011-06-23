#!/bin/sh

################################################
# ~/git/backup-scripts/backup.sh
# Lukas Kallies
# Created: Do Jun 23, 2011 - Lukas Kallies
# Last modified: Do Jun 23, 2011 - 13:59
#
# This scripts backups /etc /home /root and /var
# (in a very static way). It also runs a MySQL
# backup script and includes the (currently
# static given) file. You can specify an
# exclusion list of files (e.g. in
# /backup/exclude.example).
# 
# There is a configurable suffix which will be
# given to all files. Default is day of week
# (one digit) so backups are rotated weekly.
# 
# Afer creating the tar.gz files they will be
# encrypted with a configured gpg key and the
# resulting files will be uploaded on an ftp
# server. 
################################################

export LANG=C

GPGKEY=""
FTPUSER=""
FTPPASSWD=""
FTPSERVER=""
BACKUPPATH="/backup"
MYSQLBACKUP="./MySQLdump.sh"
EXCLUDE="/backup/exclude.example"

TAR="/bin/tar"
GPG="/usr/bin/gpg"
RM="/bin/rm"
MV="/bin/mv"
RENAME="/usr/bin/rename"
SHA1SUM="/usr/bin/sha1sum"
CAT="/bin/cat"
LFTP="/usr/bin/lftp"

SUFFIX=`date +%u`
ORG_DIR=`pwd`

#change to temp backup dir
cd ${BACKUPPATH}

#remove temp files, may be disabled
${RM} -f etc*.tar.gz home*.tar.gz var*.tar.gz root*.tar.gz mysqldump.all.sql*.gz SHA1SUM*

#create backups
echo "> creating backup for: /etc"
${TAR} pczf ${BACKUPPATH}/etc.tar.gz /etc/* --exclude=${BACKUPPATH} --exclude-from=${EXCLUDE}
echo "> creating backup for: /home"
${TAR} pczf ${BACKUPPATH}/home.tar.gz /home/* --exclude=${BACKUPPATH} --exclude-from=${EXCLUDE}
echo "> creating backup for: /root"
${TAR} pczf ${BACKUPPATH}/root.tar.gz /root/* --exclude=${BACKUPPATH} --exclude-from=${EXCLUDE}
echo "> creating backup for: /var"
${TAR} pczf ${BACKUPPATH}/var.tar.gz /var/* --exclude=${BACKUPPATH} --exclude-from=${EXCLUDE}
echo "> creating MySQL-Dump"
${MYSQLBACKUP}

#clear SHA1SUM file
${CAT} /dev/null > SHA1SUM_${SUFFIX}

${RENAME} "s/\.tar\.gz$/_${SUFFIX}\.tar\.gz/" *.tar.gz
${RENAME} "s/\.gz$/_${SUFFIX}\.gz/" mysqldump.all.sql.gz
echo "> creating checksums"
${SHA1SUM} *_${SUFFIX}*.gz >> SHA1SUM_${SUFFIX}
echo "> encrypting files"
for file in `ls *.gz`
do
	        $GPG --always-trust -r ${GPGKEY} -e ${file}
		done

#upload files
echo "> uploading backups"
${LFTP} -e "mput etc_${SUFFIX}.tar.gz.gpg home_${SUFFIX}.tar.gz.gpg var_${SUFFIX}.tar.gz.gpg root_${SUFFIX}.tar.gz.gpg mysqldump.all.sql_${SUFFIX}.gz.gpg SHA1SUM_${SUFFIX}; exit" ${FTPUSER}:${FTPPASSWD}@${FTPSERVER}

#remove encrypted files
${RM} -f ${BACKUPPATH}/*.gpg

cd ${ORG_DIR}

exit 0
