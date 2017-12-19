#!/usr/bin/env bash

## Script de purge de binlog, becoz' l'expire_logs_days de mysql est nul - Jeb

SQL_SLAVE_HOST="127.0.0.2" # set no "NONE" if no slave
SQL_HOST="127.0.0.1"
SQL_USER="root"
SQL_PASS="MonPass"
BINDIR="/var/log/mysql"
BINLOG="mariadb-bin"
RETENTION="5"


if [ $SQL_SLAVE_HOST != "NONE" ]
    then BINNOW=`/usr/bin/mysql -h$SQL_SLAVE_HOST -u$SQL_USER -p$SQL_PASS -e "show slave status\G" | grep "Relay_Master_Log_File" | cut -d . -f2`
    else BINNOW=`ls -trh $BINDIR/$BINLOG.*  | grep -v index | tail -1 | cut -d . -f2`
fi

BINTOPURGE=`expr $BINNOW - $RETENTION`

while (( `echo $BINTOPURGE | wc -c` < 7 ))

do
        BINTOPURGE="0$BINTOPURGE"
done

echo mysql-bin.$BINTOPURGE

if [ -f $BINDIR/$BINLOG.$BINTOPURGE ]
then
        /usr/bin/mysql -h$SQL_HOST -u$SQL_USER -e "purge binary logs to "\'$BINLOG.$BINTOPURGE\'"" -p$SQL_PASS
fi
