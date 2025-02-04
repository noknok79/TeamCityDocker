To install TeamCity, please follow these steps:

**Pre-requisite:** All requirements such as Docker and docker-compose are presumed to be installed.

**Step 1.** 
```bash
docker-compose up teamcity-server # Run the pulling and installation of TeamCity server images
```
To access the TeamCity GUI, open a browser and go to [http://localhost:8111](http://localhost:8111)

Proceed to the wizard. In the Database selection, choose MySQL. But before you proceed, you must run the MySQL service:
```bash
docker-compose up mysql # This will run the pulling and installation of MySQL as the database for TeamCity.
```
Once MySQL is running, proceed to select MySQL in the browser. It will continue with the setup and installation of TeamCity.

Next, you need to run the `print-volumes` service to check the IP address of your MySQL, which is required for the installation of MySQL as your database for TeamCity:
```bash
docker-compose up print-volumes # Copy the IP address of MySQL, which will be required for connecting MySQL as your database.
```
On the page for connecting to MySQL, please check the `docker-compose.yml` file for login details such as `mysql_database`, `mysql_user`, `mysql_password`, and the destination (IP address of MySQL).

Proceed to connect.

To check if TeamCity has been successfully set up, log in. Return to the CLI where you ran the teamcity-server; it will generate an authorization token to be used for the creation of an admin login.

If you have confirmed that you have successfully finished the setup of the TeamCity server, you need to run the TeamCity-Agent service:
```bash
docker-compose up teamcity-agent # This will run the pulling and installation of the TeamCity agent, which is required.
```
Check if the pulling process is done. To confirm if the installation of the TeamCity agent is completed, click on the tab on the right side and click "Agent". You will be asked to confirm the agent.

Then you are done with the installation.
You can now use TeamCity as your CICD Tools.




# Docker Compose file version declaration
version: '3.8'

# Network Configuration
# Creates an isolated network for all TeamCity components to communicate securely
networks:
  teamcity-network:
    driver: bridge  # Using bridge network driver for local development

services:
  # TeamCity Server Service
  # This is the main application server that:
  # - Hosts the web interface
  # - Manages build configurations
  # - Coordinates build agents
  # - Stores build history and artifacts
  teamcity-server:
    image: jetbrains/teamcity-server:latest  # Official TeamCity server image
    container_name: teamcity-server  # Explicit container name for easy reference
    ports:
      - "8111:8111"  # Maps host port to container port for web UI access
    volumes:
      # Persistent data storage mapping
      - teamcity-server-data:/data/teamcity_server/datadir  # Stores configurations, build history, and plugins
      - teamcity-server-logs:/opt/teamcity/logs  # Stores server logs for debugging
    environment:
      # JVM memory optimization settings
      # Xmx2g: Maximum heap size of 2GB
      # ReservedCodeCacheSize: Cache size for JIT-compiled code
      - TEAMCITY_SERVER_MEM_OPTS=-Xmx2g -XX:ReservedCodeCacheSize=350m
    networks:
      - teamcity-network  # Connects to the isolated network
    restart: unless-stopped  # Automatic restart policy
    healthcheck:  # Monitors server health
      test: ["CMD-SHELL", "curl -f http://localhost:8111 || exit 1"]
      interval: 1m30s
      timeout: 10s
      retries: 3

  # MySQL Database Service
  # Provides persistent storage for TeamCity server data including:
  # - Build configurations
  # - User data
  # - Build results
  # - Other operational data
  mysql:
    image: mysql:8.0  # Official MySQL 8.0 image
    container_name: mysql
    ports:
      - "3306:3306"  # Exposes MySQL port for external connections if needed
    environment:
      # Database configuration
      MYSQL_ROOT_PASSWORD: root_password  # Root password (change in production)
      MYSQL_DATABASE: teamcity  # Creates initial database
      MYSQL_USER: teamcity  # Creates application user
      MYSQL_PASSWORD: teamcity_password  # User password (change in production)
    volumes:
      - mysql-data:/var/lib/mysql  # Persistent database storage
      - ./mysql-init:/docker-entrypoint-initdb.d  # Initial DB setup scripts
      - ./mysql-entrypoint.sh:/docker-entrypoint.sh  # Custom entrypoint script
    networks:
      - teamcity-network
    restart: unless-stopped
    healthcheck:  # Monitors database health
      test: ["CMD-SHELL", "mysqladmin ping -h localhost || exit 1"]
      interval: 1m30s
      timeout: 10s
      retries: 3

  # TeamCity Build Agent
  # Responsible for:
  # - Executing build jobs
  # - Running tests
  # - Deploying applications
  # - Reporting results back to the server
  teamcity-agent-1:
    image: jetbrains/teamcity-agent:latest  # Official TeamCity agent image
    container_name: teamcity-agent-1
    environment:
      - SERVER_URL=http://teamcity-server:8111  # Connection to TeamCity server
    volumes:
      - teamcity-agent-config-1:/data/teamcity_agent/conf  # Agent-specific settings
    depends_on:
      - teamcity-server  # Ensures server is started first
    networks:
      - teamcity-network
    restart: unless-stopped

  # Utility Services
  # Service for debugging volume contents
  print-volumes:
    image: busybox
    volumes:
      - teamcity-server-data:/data/teamcity_server/datadir
      - teamcity-server-logs:/opt/teamcity/logs
    entrypoint: /print-volumes.sh
    networks:
      - teamcity-network

  # Maintenance service for cleaning up data
  cleanup-volumes:
    image: busybox
    command: >
      sh -c "echo 'Cleaning up local volume storage...';
             rm -rf /data/teamcity_server/datadir /opt/teamcity/logs /var/lib/mysql /docker-entrypoint-initdb.d /data/teamcity_agent/conf;
             sleep 3600"
    volumes:
      - teamcity-server-data:/data/teamcity_server/datadir
    networks:
      - teamcity-network

# Named Volumes Configuration
# Defines persistent storage locations that survive container restarts
volumes:
  teamcity-server-data:  # Persistent TeamCity server data
  teamcity-server-logs:  # Server logs storage
  mysql-data:  # Database files storage
  teamcity-agent-config-1:  # Agent 1 configuration storage
