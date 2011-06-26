#!/bin/sh

################################################
# ~/git/backup-scripts/rsync.sh
# Lukas Kallies
# Created: Do Jun 23, 2011 - Lukas Kallies
# Last modified: So Jun 26, 2011 - 11:03
#
# This script backups data via rsync. The user
# $SSHUSER needs an ssh key for the remote server
# otherwise a password will be requested.
################################################

export LANG=C

#TODO SSH_AUTH_SOCK 
#eval `ssh-agent`

EXCLUDE="/backup/exclude.example"

RSYNC="/usr/bin/rsync"
SSH="/usr/bin/ssh"

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
${RSYNC} -e "${SSH} -p ${SSHPORT}" -rlpogtz${DEBUG} --delete --delete-excluded /home ${SSHUSER}@${SSHSERVER}:${SSHPATH}/
#-----------------#
echo "-> syncing /root"
${RSYNC} -e "${SSH} -p ${SSHPORT}" -rlpogtz${DEBUG} --delete --exclude='.ssh' --exclude='.bash_history' --delete-excluded /root ${SSHUSER}@${SSHSERVER}:${SSHPATH}/
#-----------------#
#etc (apache2, mysql, email)
echo "-> syncing /etc"
${RSYNC} -e "${SSH} -p ${SSHPORT}" -rlpogtz${DEBUG} --delete /etc ${SSHUSER}@${SSHSERVER}:${SSHPATH}/
#-----------------#
#/var (mysql, email)
#TODO stop services like mysql and potfix
echo "-> syncing /var"
${RSYNC} -e "${SSH} -p ${SSHPORT}" -rlptz${DEBUG} --exclude-from=${EXCLUDE} --delete --delete-excluded /var ${SSHUSER}@${SSHSERVER}:${SSHPATH}/
#TODO start services like mysql and potfix
echo "-> disk usage"
${SSH} -p ${SSHPORT} ${SSHUSER}@${SSHSERVER} "df -h"

exit 0
