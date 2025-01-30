#!/bin/sh
echo "TeamCity Server Data: /data/teamcity_server/datadir"
echo "TeamCity Server Logs: /opt/teamcity/logs"
echo "MySQL Data: /var/lib/mysql"
echo "MySQL Init: /docker-entrypoint-initdb.d"
echo "TeamCity Agent Config: /data/teamcity_agent/conf"
MYSQL_IP=$(ping -c 1 mysql | awk -F'[()]' '/PING/{print $2}')
echo "MySQL IP Address: $MYSQL_IP"
sleep 3600

