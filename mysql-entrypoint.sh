#!/bin/bash
set -e

# Run the original entrypoint script to set up MySQL
/docker-entrypoint.sh mysqld &

# Wait for MySQL to start
sleep 10

# Get the IP address of the MySQL container
MYSQL_IP=$(hostname -i)
echo "MySQL IP Address: $MYSQL_IP"

# Keep the container running
wait

