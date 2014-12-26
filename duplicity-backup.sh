#!/usr/bin/env bash

export LC_ALL=C
export PATH="/bin:/usr/bin"

# Where to store the backups? See duplicity(1) URL FORMAT
BACKUPPATH="rsync://root@backup.example.com//backup/${HOSTNAME}"
#                                          ^^ (sic!)

# What to include?
INCLUDE="/etc /root /var /opt /home"

# for asymmetric encryption:
#GPGOPTS="--encrypt-key 01234567"
#
# for symmetric encryption:
GPGOPTS=""
export PASSPHRASE="replaceme"

EXCLUDE=""
for path in ${INCLUDE}; do
    # if backing up to /home
    if [ "/home" = "${path}" ]; then
   	    EXCLUDE="--exclude ${path}/backup --exclude ${path}/www"
    fi
    duplicity ${EXCLUDE} ${GPGOPTS} ${path} ${BACKUPPATH}/${path}
    EXCLUDE=""
done

exit 0

vim: tabstop=4:softtabstop=4:shiftwidth=4:expandtab
