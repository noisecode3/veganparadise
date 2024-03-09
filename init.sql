DROP DATABASE IF EXISTS broccoli;
CREATE DATABASE IF NOT EXISTS broccoli;

USE broccoli;
SET NAMES utf8mb4;

CREATE USER IF NOT EXISTS 'veganburger'@'%' IDENTIFIED BY 'tofu';
GRANT ALL PRIVILEGES ON broccoli.* TO 'veganburger'@'%';
FLUSH PRIVILEGES;

CREATE TABLE IF NOT EXISTS picture (
  id INT PRIMARY KEY AUTO_INCREMENT,
  hight INT,
  width  INT,
  fileType TEXT NOT NULL,
  data MEDIUMBLOB NOT NULL
);

CREATE TABLE IF NOT EXISTS users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(255) UNIQUE NOT NULL,
  password VARBINARY(255) NOT NULL,
  salt VARBINARY(64) UNIQUE NOT NULL,
  pictureId INT UNIQUE,
  FOREIGN KEY (pictureId) REFERENCES picture(id)
);

ALTER TABLE users AUTO_INCREMENT = 1;

-- CREATE USER IF NOT EXISTS 'readOnlyUser'@'%' IDENTIFIED BY 'readOnlyPassword';
-- GRANT SELECT ON broccoli.users TO 'readOnlyUser'@'%';

-- CREATE USER IF NOT EXISTS 'readWriteUser'@'%' IDENTIFIED BY 'readWritePassword';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON broccoli.users TO 'readWriteUser'@'%';

CREATE TABLE IF NOT EXISTS recipe (
  id INT AUTO_INCREMENT PRIMARY KEY,
  userId INT NOT NULL,
  name TEXT NOT NULL,
  pictureId INT NOT NULL,
  time INT NOT NULL,
  body TEXT NOT NULL,
  FOREIGN KEY (userId) REFERENCES users(id),
  FOREIGN KEY (pictureId) REFERENCES picture(id)
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
  quantity INT,
  unit TEXT,
  variant TEXT,
  PRIMARY KEY (itemId, recipeId),
  FOREIGN KEY (itemId) REFERENCES item(id),
  FOREIGN KEY (recipeId) REFERENCES recipe(id)
);

-- Middle table for item in the store 
CREATE TABLE IF NOT EXISTS products (
  itemId INT NOT NULL,
  storeId INT NOT NULL,
  price INT NOT NULL,
  PRIMARY KEY (itemId, storeId),
  FOREIGN KEY (itemId) REFERENCES item(id),
  FOREIGN KEY (storeId) REFERENCES store(id)
);

DELIMITER //

CREATE PROCEDURE insertPicture(
  IN p_data MEDIUMBLOB,
  OUT p_pictureId INT
)
BEGIN
  
SET @fileType = 
  CASE
    WHEN SUBSTRING(p_data, 1, 2) = 0xFFD8 THEN 'image/jpeg'
    WHEN SUBSTRING(p_data, 1, 3) = 0x89504E THEN 'image/png'
    WHEN SUBSTRING(p_data, 1, 4) = 0x52494646 THEN 'image/webp'
    ELSE 'UNKNOWN'
  END;
  INSERT INTO picture (fileType, data)
  VALUES (@fileType, p_data);

  SET p_pictureId = LAST_INSERT_ID();
END //

-- users data

CREATE PROCEDURE insertUser(
    IN p_username VARCHAR(255),
    IN p_password VARCHAR(255),
    IN p_pictureData MEDIUMBLOB
)
BEGIN
  DECLARE pictureId INT;
  
  -- Generate a random salt
  SET @salt = UNHEX(SHA2(UUID(), 256));

  -- Hash the password with the salt
  SET @hashed_password = SHA2(CONCAT(p_password, HEX(@salt)), 256);

  CALL insertPicture(p_pictureData, @pictureId);

  INSERT INTO users (username, password, salt, pictureId)
    VALUES (p_username, @salt, @hashed_password, @pictureId);

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

-- CREATE PROCEDURE changePicture(IN p_id INT, IN p_picture BLOB)
-- BEGIN
--   CALL insertPicture(p_picture, @pictureId);

--   UPDATE users SET pictureId = @pictureId WHERE users.id = p_id;
-- END //

-- recipes data


CREATE PROCEDURE insertRecipe(
  IN p_userID INT,
  IN p_name TEXT,
  IN p_picture MEDIUMBLOB,
  IN p_time INT,
  IN p_body TEXT)
BEGIN
  CALL insertPicture(p_picture, @pictureId);
  
  INSERT IGNORE INTO recipe (userId, name, pictureId, time, body )
    VALUES (p_userID, p_name, @pictureId, p_time, p_body );
END //

CREATE PROCEDURE removeRecipe(IN p_id INT)
BEGIN
  DELETE FROM recipe WHERE recipe.id = p_id;
END //

CREATE PROCEDURE getRecipeList()
BEGIN
  SELECT recipe.id, recipe.name, recipe.pictureId, picture.fileType
  FROM recipe
  JOIN picture ON recipe.pictureId = picture.id;
END //

CREATE PROCEDURE getPicture(IN p_id INT)
BEGIN
  SELECT picture.data, picture.fileType FROM picture WHERE picture.id = p_id;
END //

CREATE PROCEDURE getRecipeUserList(IN p_userid INT)
BEGIN
  SELECT id, name, pictureId FROM recipe WHERE recipe.userId = p_userid;
END //

CREATE PROCEDURE getRecipe(IN p_id INT)
BEGIN
  SELECT userId, name, pictureId, time, body FROM recipe WHERE recipe.id = p_id;
END //

CREATE PROCEDURE changeRecipeName(IN p_id INT)
BEGIN
  UPDATE recipe SET name = p_name WHERE recipe.id = p_id;
END //

-- CREATE PROCEDURE changeRecipePicture(IN p_id INT, IN p_picture INT)
-- BEGIN
--   UPDATE recipe SET picture = p_picture WHERE recipe.id = p_id;
-- END //

CREATE PROCEDURE changeRecipeTime(IN p_id INT)
BEGIN
  UPDATE recipe SET time = p_time WHERE recipe.id = p_id;
END //

CREATE PROCEDURE changeRecipeBody(IN p_id INT)
BEGIN
  UPDATE recipe SET body = p_body WHERE recipe.id = p_id;
END //

-- Item data

CREATE PROCEDURE insertItem(IN p_name TEXT)
BEGIN
  INSERT IGNORE INTO item (name) VALUES (p_name);
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


CREATE PROCEDURE addOrUpdateItem(IN p_name TEXT, OUT p_itemId INT)
BEGIN
  DECLARE itemId INT;

  SELECT id INTO itemId FROM item WHERE name = p_name LIMIT 1;

  IF itemId IS NULL THEN
    CALL insertItem(p_name);
    -- INSERT INTO item (name) VALUES (p_name);
    SET p_itemId = LAST_INSERT_ID();
  END IF;
END //

CREATE PROCEDURE addItemToRecipe(
  IN p_itemId INT,
  IN p_recipeId INT,
  IN p_quantity INT,
  IN p_variant TEXT,
  IN p_unit TEXT)
BEGIN
  INSERT IGNORE INTO ingredients (itemId, recipeId, quantity, unit, variant)
  VALUES (p_itemId, p_recipeId, p_quantity, p_unit, p_variant);
END //

CREATE PROCEDURE addIngredientToRecipe(
  IN p_itemName TEXT,
  IN p_recipeId INT,
  IN p_quantity INT,
  IN p_unit TEXT,
  IN p_variant TEXT
)
BEGIN
  DECLARE itemId INT;
  CALL addOrUpdateItem(p_itemName, itemId);
  CALL addItemToRecipe(itemId, p_recipeId, p_quantity, p_unit, p_variant);
END //

CREATE PROCEDURE addItemToStore(
  IN p_itemId INT,
  IN p_storeId INT,
  IN p_price INT)
BEGIN
  INSERT IGNORE INTO products (itemId, storeId, price)
  VALUES (p_itemId, p_storeId, p_price);
END //

CREATE PROCEDURE insertStore(
  IN p_name TEXT,
  IN p_url TEXT,
  IN p_district TEXT)
BEGIN
  INSERT IGNORE INTO store (name, url, district)
  VALUES (p_name, p_url, p_district);
END //

DELIMITER ;
