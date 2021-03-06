#!/bin/sh

################################################
# ~/git/backup-scripts/rsync.sh
# Lukas Kallies
# Created: Do Jun 23, 2011 - Lukas Kallies
# Last modified: Mi Jun 15, 2016 - 10:18
#
# This script backups data via rsync. The user
# $SSHUSER needs an ssh key for the remote server
# otherwise a password will be requested.
#
# Published under the MIT License (MIT)
################################################

export LANG=C
export PATH="/bin:/usr/bin"

#TODO SSH_AUTH_SOCK 
#eval `ssh-agent`

EXCLUDE="/backup/exclude.example"

DELETEEXCLUDED="--delete-excluded"

RSYNC="rsync"
SSH="ssh"

SSHSERVER=""
SSHPORT="22"
SSHUSER="root"
SSHPATH="/backup"

DEBUG=""
if [ "--debug" = "$1" ]
then
	DEBUG="v"
fi

#-----------------#
echo "-> syncing /home"
${RSYNC} -e "${SSH} -p ${SSHPORT}" -rlpogtz${DEBUG} --delete ${DELETEEXCLUDED} /home ${SSHUSER}@${SSHSERVER}:${SSHPATH}/
#-----------------#
echo "-> syncing /root"
${RSYNC} -e "${SSH} -p ${SSHPORT}" -rlpogtz${DEBUG} --delete --exclude='.ssh' --exclude='.bash_history' ${DELETEEXCLUDED} /root ${SSHUSER}@${SSHSERVER}:${SSHPATH}/
#-----------------#
#etc (apache2, mysql, email)
echo "-> syncing /etc"
${RSYNC} -e "${SSH} -p ${SSHPORT}" -rlpogtz${DEBUG} --delete ${DELETEEXCLUDED} /etc ${SSHUSER}@${SSHSERVER}:${SSHPATH}/
#-----------------#
#/var (mysql, email)
#TODO stop services like mysql and postfix
echo "-> syncing /var"
${RSYNC} -e "${SSH} -p ${SSHPORT}" -rlptz${DEBUG} --exclude-from=${EXCLUDE} --delete ${DELETEEXCLUDED} /var ${SSHUSER}@${SSHSERVER}:${SSHPATH}/
#TODO start services like mysql and postfix
echo "-> disk usage"
${SSH} -p ${SSHPORT} ${SSHUSER}@${SSHSERVER} "df -h ${SSHPATH}"

exit 0
