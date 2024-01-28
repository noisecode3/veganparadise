DROP DATABASE IF EXISTS broccoli;
CREATE DATABASE IF NOT EXISTS broccoli;

USE broccoli;

CREATE USER IF NOT EXISTS 'veganburger'@'%' IDENTIFIED BY 'tofu';
GRANT ALL PRIVILEGES ON broccoli.* TO 'veganburger'@'%';
FLUSH PRIVILEGES;

CREATE TABLE IF NOT EXISTS users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL
);

CREATE USER IF NOT EXISTS 'read_only_user'@'%' IDENTIFIED BY 'read_only_password';
GRANT SELECT ON broccoli.users TO 'read_only_user'@'%';

CREATE USER IF NOT EXISTS 'read_write_user'@'%' IDENTIFIED BY 'read_write_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON broccoli.users TO 'read_write_user'@'%';

