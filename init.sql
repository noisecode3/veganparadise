DROP DATABASE IF EXISTS broccoli;
CREATE DATABASE IF NOT EXISTS broccoli;

USE broccoli;
SET NAMES utf8mb4;

CREATE USER IF NOT EXISTS 'veganburger'@'%' IDENTIFIED BY 'tofu';
GRANT ALL PRIVILEGES ON broccoli.* TO 'veganburger'@'%';
FLUSH PRIVILEGES;

CREATE TABLE IF NOT EXISTS users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  salt VARCHAR(255) UNIQUE NOT NULL,
  picture BLOB
);

CREATE USER IF NOT EXISTS 'readOnlyUser'@'%' IDENTIFIED BY 'readOnlyPassword';
GRANT SELECT ON broccoli.users TO 'readOnlyUser'@'%';

CREATE USER IF NOT EXISTS 'readWriteUser'@'%' IDENTIFIED BY 'readWritePassword';
GRANT SELECT, INSERT, UPDATE, DELETE ON broccoli.users TO 'readWriteUser'@'%';

CREATE TABLE IF NOT EXISTS recipe (
  id INT AUTO_INCREMENT PRIMARY KEY,
  userId INT NOT NULL,
  name TEXT NOT NULL,
  time INT NOT NULL,
  cost INT NOT NULL,
  body TEXT NOT NULL,
  picture BLOB,
  FOREIGN KEY (userId) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS item (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS store (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL,
  url TEXT,
  district TEXT
);

-- Middle table for item used in the recipe
CREATE TABLE IF NOT EXISTS ingredients (
  itemId INT NOT NULL,
  recipeId INT NOT NULL,
  FOREIGN KEY (itemId) REFERENCES item(id),
  FOREIGN KEY (recipeId) REFERENCES recipe(id)
);

-- Middle table for item in the store 
CREATE TABLE IF NOT EXISTS products (
  itemId INT NOT NULL,
  storeId INT NOT NULL,
  FOREIGN KEY (itemId) REFERENCES item(id),
  FOREIGN KEY (storeId) REFERENCES store(id)
);

DELIMITER //

-- users data
-- id INT PRIMARY KEY AUTO_INCREMENT
-- username VARCHAR(255) UNIQUE NOT NULL
-- password VARCHAR(255) NOT NULL
-- salt VARCHAR(255) UNIQUE NOT NULL
-- picture BLOB

CREATE PROCEDURE insertUser(IN p_username VARCHAR(255), IN p_password VARCHAR(255))
BEGIN
  -- Generate a random salt
  SET @salt = UNHEX(SHA2(UUID(), 256)); -- Use SHA2 to create a 256-bit salt

  -- Hash the password with the salt
  SET @hashed_password = SHA2(CONCAT(p_password, HEX(@salt)), 256);

  -- Insert the username, salt, and hashed password into the users table
  INSERT INTO users (username, salt, password) VALUES (p_username, @salt, @hashed_password);
END //

CREATE PROCEDURE getUserID(IN p_username VARCHAR(255), IN p_password VARCHAR(255))
BEGIN
  -- Retrieve the salt for the given username
  SELECT salt INTO @salt FROM users WHERE username = p_username;

  -- Hash the input password with the retrieved salt
  SET @hashed_input_password = SHA2(CONCAT(p_password, HEX(@salt)), 256);

  -- Retrieve the userID based on the username and hashed password
  SELECT userID FROM users WHERE username = p_username AND password = @hashed_input_password;
END //

CREATE PROCEDURE changePicture(IN p_id INT, IN p_picture BLOB)
BEGIN
  UPDATE users SET picture = p_picture WHERE users.id = p_id;
END //

-- recipes data
-- id INT AUTO_INCREMENT PRIMARY KEY
--  userID INT NOT NULL FOREIGN KEY
--  name TEXT NOT NULL
--  time INT NOT NULL
--  cost INT NOT NULL
--  body TEXT NOT NULL
--  picture BLOB

CREATE PROCEDURE insertRecipe(
  IN p_userID INT,
  IN p_name TEXT,
  IN p_time INT,
  IN p_cost INT,
  IN p_body TEXT,
  IN p_picture BLOB)
BEGIN
  INSERT INTO recipe (userID, name, time, cost, body, picture)
    VALUES (p_userID, p_name, p_time, p_cost, p_body, p_picture);
END //

CREATE PROCEDURE removeRecipe(IN p_id INT)
BEGIN
  DELETE FROM recipe WHERE recipe.id = p_id;
END //

CREATE PROCEDURE getRecipeList()
BEGIN
  SELECT id, name, picture FROM recipe;
END //

CREATE PROCEDURE getRecipeUserList(IN p_userid INT)
BEGIN
  SELECT id, name, picture FROM recipe WHERE recipe.userID = p_userid;
END //

CREATE PROCEDURE getRecipe(IN p_id INT)
BEGIN
  SELECT name, time, cost, body, picture FROM recipe WHERE recipe.id = p_id;
END //

CREATE PROCEDURE changeRecipeName(IN p_id INT)
BEGIN
  UPDATE recipe SET name = p_name WHERE recipe.id = p_id;
END //

CREATE PROCEDURE changeRecipeTime(IN p_id INT)
BEGIN
  UPDATE recipe SET time = p_time WHERE recipe.id = p_id;
END //

CREATE PROCEDURE changeRecipeCost(IN p_id INT)
BEGIN
  UPDATE recipe SET cost = p_cost WHERE recipe.id = p_id;
END //

CREATE PROCEDURE changeRecipeBody(IN p_id INT)
BEGIN
  UPDATE recipe SET body = p_body WHERE recipe.id = p_id;
END //

CREATE PROCEDURE changeRecipePicture(IN p_id INT)
BEGIN
  UPDATE recipe SET picture = p_picture WHERE recipe.id = p_id;
END //

-- Item data
-- id INT AUTO_INCREMENT PRIMARY KEY
-- name VARCHAR(255) UNIQUE NOT NULL

CREATE PROCEDURE insertItem(IN p_name TEXT)
BEGIN
  INSERT INTO item (name) VALUES (p_name);
END //

CREATE PROCEDURE removeItem(IN p_id INT)
BEGIN
  DELETE FROM item WHERE item.id = p_id;
END //

CREATE PROCEDURE getItemName(IN p_id INT)
BEGIN
  SELECT name FROM item WHERE item.id = p_id;
END //

CREATE PROCEDURE getItemId(IN p_name TEXT)
BEGIN
  SELECT id FROM item WHERE item.name = p_name;
END //

CREATE PROCEDURE addItemToRecipe(IN p_itemId INT, IN p_recipeId INT)
BEGIN
  INSERT INTO ingredients (itemId, recipeId) VALUES (p_itemId, p_recipeId);
END //

CREATE PROCEDURE addItemToStore(IN p_itemId INT, IN p_storeId INT)
BEGIN
  INSERT INTO ingredients (itemId, storeId) VALUES (p_itemId, p_storeId);
END //

CREATE PROCEDURE insertStore(
  IN p_name TEXT,
  IN p_url TEXT,
  IN p_district TEXT)
BEGIN
  INSERT IGNORE INTO store (name, url, district) VALUES (p_name, p_url, p_district);
END //

DELIMITER ;
