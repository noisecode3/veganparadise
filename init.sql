DROP DATABASE IF EXISTS broccoli;
CREATE DATABASE IF NOT EXISTS broccoli;

USE broccoli;

CREATE USER IF NOT EXISTS 'veganburger'@'%' IDENTIFIED BY 'tofu';
GRANT ALL PRIVILEGES ON broccoli.* TO 'veganburger'@'%';
FLUSH PRIVILEGES;

CREATE TABLE IF NOT EXISTS users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  picture BLOB
);

CREATE USER IF NOT EXISTS 'read_only_user'@'%' IDENTIFIED BY 'read_only_password';
GRANT SELECT ON broccoli.users TO 'read_only_user'@'%';

CREATE USER IF NOT EXISTS 'read_write_user'@'%' IDENTIFIED BY 'read_write_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON broccoli.users TO 'read_write_user'@'%';

CREATE TABLE IF NOT EXISTS recipe (
  id INT AUTO_INCREMENT PRIMARY KEY,
  userID INT NOT NULL,
  name TEXT NOT NULL,
  time INT NOT NULL,
  cost INT NOT NULL,
  body TEXT NOT NULL,
  picture BLOB,
  FOREIGN KEY (userID) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS item (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS store (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name TEXT NOT NULL,
  url TEXT,
  district TEXT
);

CREATE TABLE IF NOT EXISTS ingredients (
  recipeID INT,
  itemID INT,
  FOREIGN KEY (recipeID) REFERENCES recipe(id),
  FOREIGN KEY (itemID) REFERENCES item(id)
);

CREATE TABLE IF NOT EXISTS products (
  itemID INT,
  storeID INT,
  FOREIGN KEY (itemID) REFERENCES item(id),
  FOREIGN KEY (storeID) REFERENCES store(id)
);

DELIMITER //

CREATE PROCEDURE insertUser(IN p_username VARCHAR(255), IN p_password VARCHAR(255))
BEGIN
  -- Check if p_password is a valid SHA-256 hash (64 hexadecimal characters)
  IF LENGTH(p_password) = 64 AND p_password REGEXP '^[0-9a-fA-F]+$' AND LENGTH(p_username) = 64 AND p_username REGEXP '^[0-9a-fA-F]+$' THEN
    INSERT INTO users (username, password) VALUES (p_username, p_password);
  ELSE
    -- Handle the case where p_password is not a valid SHA-256 hash
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Invalid SHA-256 hash format';
  END IF;
END //

CREATE PROCEDURE getUserID(IN p_username VARCHAR(255), IN p_password VARCHAR(255))
BEGIN
  SELECT userID FROM users WHERE username=p_username AND password=p_password;
END //

DELIMITER ;

--CREATE USER 'your_username'@'your_host' IDENTIFIED BY 'your_password';

--GRANT EXECUTE ON PROCEDURE your_database.your_stored_procedure TO 'your_username'@'your_host';
