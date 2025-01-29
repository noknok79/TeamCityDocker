CREATE DATABASE IF NOT EXISTS teamcity;
USE teamcity;

-- Example table creation
CREATE TABLE IF NOT EXISTS build_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    build_number VARCHAR(255) NOT NULL,
    status VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add more table creation statements as needed

