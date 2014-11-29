#!/bin/sh

################################################
# ~/git/backup-scripts/backup.sh
# Lukas Kallies
# Created: Do Jun 23, 2011 - Lukas Kallies
# Last modified: Sa Nov 29, 2014 - 20:59
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

export LC_ALL=C
export PATH="/bin:/usr/bin"

#gpg key to encrypt with, e.g. 0x12341234
GPGKEY=""
#ftp user, password and server
FTPUSER=""
FTPPASSWD=""
FTPSERVER=""
FTPUPLOAD="NO" #YES|NO
#where should the script place its (temporary) files?
BACKUPPATH="/backup"
UPLOADPATH="/backup/hubic"
#which backup script for MySQL should be started?
MYSQLBACKUP="./MySQLdump.sh"
BACKUPMYSQL="NO" #YES|NO
#exclude the files mentioned in the following file
EXCLUDE="/backup/exclude.example"
#include the following dirs (without leading or trailing slash)
INCLUDE="etc home var root opt"
#Suffix for backupfiles, e.g. `date +%u` for weekly rotation or "x" for no rotation
SUFFIX=`date +%u`

TAR="tar"
GPG="gpg"
RM="rm"
MV="mv"
RENAME="rename"
SHA1SUM="sha1sum"
CAT="cat"
LFTP="lftp"

ORG_DIR=`pwd`
#change to temp backup dir
cd ${BACKUPPATH}

#create filelists
FILELIST=""
GPGFILELIST=""
for file in ${INCLUDE}
do
	FILELIST="${file}_${SUFFIX}.tar.gz ${FILELIST}"
	GPGFILELIST="${file}_${SUFFIX}.tar.gz.gpg ${GPGFILELIST}"
done
GPGFILELIST="${GPGFILELIST} mysqldump.all.sql_${SUFFIX}.gz.gpg"

#remove temp files
${RM} -f ${BACKUPPATH}/*.tar.gz mysqldump.all.sql*.gz SHA1SUM*

#create backups
for path in ${INCLUDE}
do
	echo "> creating backup for: /${path}"
	${TAR} pczf ${BACKUPPATH}/${path}.tar.gz /${path} --exclude=${BACKUPPATH} --exclude-from=${EXCLUDE}
done
#TODO check for backupmysql
echo "> creating MySQL-Dump"
${MYSQLBACKUP}

${RENAME} "s/\.tar\.gz$/_${SUFFIX}\.tar\.gz/" *.tar.gz
${RENAME} "s/\.gz$/_${SUFFIX}\.gz/" mysqldump.all.sql.gz
echo "> creating checksums"
${SHA1SUM} *_${SUFFIX}*.gz >> SHA1SUM_${SUFFIX}
echo "> encrypting files"
for file in `ls *.gz`
do
	${GPG} --always-trust -r ${GPGKEY} -e ${file}
done

if [ ${FTPUPLOAD} = "YES" ]
then
	#upload files
	echo "> uploading backups"
	${LFTP} -e "mput ${GPGFILELIST} SHA1SUM_${SUFFIX}; exit" ${FTPUSER}:${FTPPASSWD}@${FTPSERVER}
else
	${MV} -t ${UPLOADPATH} ${GPGFILELIST} SHA1SUM_${SUFFIX}
fi

#remove encrypted files
${RM} -f ${GPGFILELIST}

cd ${ORG_DIR}

exit 0
