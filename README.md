backup-scripts
====================
This is a collection of backup scripts for GNU/Linux.

This includes simple backup mechanisms for directories like /home and /etc
and other things like MySQL dump. They are aiming on root servers most
likely running on Debian GNU/Linux.

For a more advanced usage you might want to use [duplicity](http://duplicity.nongnu.org/).

MySQLdump.sh
------------
Creates a dump from all MySQL databases on the host. Reads password from
/etc/mysql/debian.cnf

backup.sh
---------
Creates GPG encrypted backups (e.g. for unencrypted transfers like ftp)

rsync.sh
--------
Creates backups via rsync (/home, /root, /etc, /var)

duplicity-backup.sh
-------------------
Simple calls for a duplicity based backup script.
