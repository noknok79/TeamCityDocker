-- Create the TeamCity database if it doesn't exist
CREATE DATABASE IF NOT EXISTS teamcity;

-- Create the TeamCity user if it doesn't exist and grant necessary privileges
CREATE USER IF NOT EXISTS 'teamcity'@'%' IDENTIFIED BY 'teamcity_password';
GRANT ALL PRIVILEGES ON teamcity.* TO 'teamcity'@'%';
FLUSH PRIVILEGES;

-- Use the TeamCity database
USE teamcity;

-- Add any required table creation scripts for TeamCity here

