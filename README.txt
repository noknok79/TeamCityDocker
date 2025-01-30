version: '3.8' # Specifies the version of the Docker Compose file format to use.

services: 
  teamcity-server: # Defines a service named "teamcity-server".
    image: jetbrains/teamcity-server # The Docker image to use for this service.
    container_name: teamcity-server # Sets a custom name for the container.
    ports:
      - "8111:8111" # Maps port 8111 on the host to port 8111 on the container.
    volumes:
      - teamcity-server-data:/data/teamcity_server/datadir # Persists the TeamCity server data directory.
      - teamcity-server-logs:/opt/teamcity/logs # Persists the TeamCity server logs directory.
    environment:
      - TEAMCITY_SERVER_MEM_OPTS=-Xmx2g -XX:ReservedCodeCacheSize=350m # Sets Java memory options for the TeamCity server.

  mysql: # Defines a service named "mysql".
    image: mysql:latest # The Docker image to use for this service.
    container_name: mysql # Sets a custom name for the container.
    ports:
      - "3306:3306" # Maps port 3306 on the host to port 3306 on the container.
    environment:
      MYSQL_ROOT_PASSWORD: root_password # Sets the MySQL root password.
      MYSQL_DATABASE: teamcity # Creates a database named "teamcity".
      MYSQL_USER: teamcity # Creates a MySQL user named "teamcity".
      MYSQL_PASSWORD: teamcity_password # Sets the password for the "teamcity" user.
    volumes:
      - mysql-data:/var/lib/mysql # Persists the MySQL data directory.
      - ./mysql-init:/docker-entrypoint-initdb.d # Mounts initialization scripts from the host directory.
      - ./mysql-entrypoint.sh:/docker-entrypoint.sh # Mounts a custom entrypoint script from the host directory.

  teamcity-agent: # Defines a service named "teamcity-agent".
    image: jetbrains/teamcity-agent # The Docker image to use for this service.
    container_name: teamcity-agent # Sets a custom name for the container.
    environment:
      - SERVER_URL=http://teamcity-server:8111 # Sets the URL of the TeamCity server.
    volumes:
      - teamcity-agent-config:/data/teamcity_agent/conf # Persists the TeamCity agent configuration directory.
    depends_on:
      - teamcity-server # Ensures that the "teamcity-server" service is started before this service.

  print-volumes: # Defines a utility service for printing the list of volumes and their contents.
    image: busybox # The Docker image to use for this utility service (busybox is a lightweight image for utility tasks).
    volumes:
      - teamcity-server-data:/data/teamcity_server/datadir # Mounts the volume used by the TeamCity server data directory.
      - teamcity-server-logs:/opt/teamcity/logs # Mounts the volume used by the TeamCity server logs directory.
      - mysql-data:/var/lib/mysql # Mounts the volume used by the MySQL data directory.
      - ./mysql-init:/docker-entrypoint-initdb.d # Mounts the initialization scripts from the host directory.
      - teamcity-agent-config:/data/teamcity_agent/conf # Mounts the volume used by the TeamCity agent configuration directory.
      - ./print-volumes.sh:/print-volumes.sh # Mounts a custom script from the host directory to print volume contents.
    entrypoint: /print-volumes.sh # Specifies the entry point to run the custom script.

  cleanup-volumes: # Defines a utility service for cleaning up local volume storage.
    image: busybox # The Docker image to use for this utility service (busybox is a lightweight image for utility tasks).
    command: >
      sh -c "echo 'Cleaning up local volume storage...'; 
             rm -rf /data/teamcity_server/datadir /opt/teamcity/logs /var/lib/mysql /docker-entrypoint-initdb.d /data/teamcity_agent/conf; 
             sleep 3600" # Custom command to delete volume contents and keep the container running for an hour.
    volumes:
      - teamcity-server-data:/data/teamcity_server/datadir # Mounts the volume used by the TeamCity server data directory.
      - teamcity-server-logs:/opt/teamcity/logs # Mounts the volume used by the TeamCity server logs directory.
      - mysql-data:/var/lib/mysql # Mounts the volume used by the MySQL data directory.
      - ./mysql-init:/docker-entrypoint-initdb.d # Mounts the initialization scripts from the host directory.
      - teamcity-agent-config:/data/teamcity_agent/conf # Mounts the volume used by the TeamCity agent configuration directory.

volumes: # Defines the named volumes to persist data.
  teamcity-server-data: # Volume for TeamCity server data directory.
  teamcity-server-logs: # Volume for TeamCity server logs directory.
  mysql-data: # Volume for MySQL data directory.
  teamcity-agent-config: # Volume for TeamCity agent configuration directory.

