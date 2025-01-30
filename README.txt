version: '3.8' # Specifies the version of Docker Compose syntax being used

services: 
  teamcity-server: # Definition of the TeamCity server service
    image: jetbrains/teamcity-server # Specifies the image to use
    container_name: teamcity-server # Sets a custom name for the container
    ports:
      - "8111:8111" # Maps port 8111 on the host to port 8111 on the container
    volumes:
      - teamcity-server-data:/data/teamcity_server/datadir # Persistent data storage for TeamCity server data directory
      - teamcity-server-logs:/opt/teamcity/logs # Persistent data storage for TeamCity server logs
    environment:
      - TEAMCITY_SERVER_MEM_OPTS=-Xmx2g -XX:ReservedCodeCacheSize=350m # Sets memory options for the TeamCity server

  mysql: # Definition of the MySQL service
    image: mysql:latest # Specifies the image to use
    container_name: mysql # Sets a custom name for the container
    ports:
      - "3306:3306" # Maps port 3306 on the host to port 3306 on the container
    environment:
      MYSQL_ROOT_PASSWORD: root_password # Sets the root password for MySQL
      MYSQL_DATABASE: teamcity # Creates a database named 'teamcity'
      MYSQL_USER: teamcity # Creates a user named 'teamcity'
      MYSQL_PASSWORD: teamcity_password # Sets the password for the 'teamcity' user
    volumes:
      - mysql-data:/var/lib/mysql # Persistent data storage for MySQL data
      - ./mysql-init:/docker-entrypoint-initdb.d # Initializes MySQL with scripts from the host directory
      - ./mysql-entrypoint.sh:/docker-entrypoint.sh # Custom entrypoint script for MySQL

  teamcity-agent: # Definition of the TeamCity agent service
    image: jetbrains/teamcity-agent # Specifies the image to use
    container_name: teamcity-agent # Sets a custom name for the container
    environment:
      - SERVER_URL=http://teamcity-server:8111 # Sets the URL for the TeamCity server
    volumes:
      - teamcity-agent-config:/data/teamcity_agent/conf # Persistent data storage for TeamCity agent configuration
    depends_on: # Ensures the TeamCity server service is started before this service
      - teamcity-server

  print-volumes: # Utility service to print the list of volumes and their contents
    image: busybox # Specifies the image to use (busybox for utility tasks)
    volumes:
      - teamcity-server-data:/data/teamcity_server/datadir
      - teamcity-server-logs:/opt/teamcity/logs
      - mysql-data:/var/lib/mysql
      - ./mysql-init:/docker-entrypoint-initdb.d
      - teamcity-agent-config:/data/teamcity_agent/conf
      - ./print-volumes.sh:/print-volumes.sh # Custom script to print volume contents
    entrypoint: /print-volumes.sh # Entry point to run the custom script

  cleanup-volumes: # Utility service to clean up local volume storage
    image: busybox # Specifies the image to use (busybox for utility tasks)
    command: >
      sh -c "echo 'Cleaning up local volume storage...';
             rm -rf /data/teamcity_server/datadir /opt/teamcity/logs /var/lib/mysql /docker-entrypoint-initdb.d /data/teamcity_agent/conf;
             sleep 3600" # Command to delete volume contents and keep container running for an hour
    volumes:
      - teamcity-server-data:/data/teamcity_server/datadir
      - teamcity-server-logs:/opt/teamcity/logs
      - mysql-data:/var/lib/mysql
      - ./mysql-init:/docker-entrypoint-initdb.d
      - teamcity-agent-config:/data/teamcity_agent/conf

volumes: # Defines named volumes to persist data
  teamcity-server-data:
  teamcity-server-logs:
  mysql-data:
  teamcity-agent-config:

