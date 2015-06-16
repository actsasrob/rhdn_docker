#!/bin/bash

# Helper function
function error_exit
{
  echo "$1"
  logger -t $0 "$1"
  exit 1
}

WRK_DIR=/home/app/webapp

echo "env"
env

echo "whoami"
whoami

echo "id"
id

echo "ls -l $WRK_DIR/config"
ls -l $WRK_DIR/config

echo "ls -l $WRK_DIR"
ls -l $WRK_DIR

# sed-fu to update database info in database.yml
# If environment variables were passed into the containers then use those values, otherwise see if environments variables were created due to a linked MySQL container
if [ -z "$MYSQL_DATABASE" ]; then
   MYSQL_DATABASE=$(env | grep "ENV_MYSQL_DATABASE" | tail -1 | awk -F= '{print $2}')
fi
if [ -z "$MYSQL_USER" ]; then
   MYSQL_USER=$(env | grep "ENV_MYSQL_USER" | tail -1 | awk -F= '{print $2}')
fi
if [ -z "$MYSQL_PASSWORD" ]; then
   MYSQL_PASSWORD=$(env | grep "ENV_MYSQL_PASSWORD" | tail -1 | awk -F= '{print $2}')
fi
if [ -z "$MYSQL_HOSTNAME" ]; then
   MYSQL_HOSTNAME=$(env | grep "MYSQL.*TCP_ADDR=" | tail -1 | awk -F= '{print $2}')
fi
echo "$MYSQL_PORT" | grep : > /dev/null 2>&1
if [ "$?" -eq 0 ]; then
   MYSQL_PORT=$(echo "$MYSQL_PORT" | tail -1 | awk -F: '{print $NF}')
fi
if [ -z "$MYSQL_PORT" ]; then
   MYSQL_PORT=$(env | grep "MYSQL.*TCP_PORT=" | tail -1 | awk -F= '{print $2}')
fi

echo "here MYSQL_DATABASE=$MYSQL_DATABASE"
echo "here MYSQL_USER=$MYSQL_USER"
echo "here MYSQL_PASSWORD=$MYSQL_PASSWORD"
echo "here MYSQL_HOSTNAME=$MYSQL_HOSTNAME"

sed -i -e "s/database:.*/database: $MYSQL_DATABASE/" $WRK_DIR/config/database.yml
sed -i -e "s/username:.*/username: $MYSQL_USER/" $WRK_DIR/config/database.yml
sed -i -e "s/password:.*/password: $MYSQL_PASSWORD/" $WRK_DIR/config/database.yml
sed -i -e "s/host:.*/host: $MYSQL_HOSTNAME/" $WRK_DIR/config/database.yml
sed -i -e "s/port:.*/port: $MYSQL_PORT/" $WRK_DIR/config/database.yml

echo "cat database.yml"
cat $WRK_DIR/config/database.yml

echo "ps -ef"
ps -ef

echo "cat /etc/hosts"
cat /etc/hosts


exit 0
