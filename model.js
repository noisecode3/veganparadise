const mysql = require('mysql2/promise');
const fs = require('fs').promises;
const retry = require('retry');
const imageSize = require('image-size');


class Model
{
  constructor()
  {
    this.stores = []; 
    this.pool = mysql.createPool({
      user: 'veganburger',
      host: 'db',
      database: 'broccoli',
      password: 'tofu',
      port: 3306,
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0,
    });
  }

  
/* imageType(buffer) {
  const type = imageType(buffer);
  if (type && (type.ext === 'jpg' || type.ext === 'png' || type.ext === 'webp')) {
    return type.ext;
  }
  console.log('Not a valid image');
  return null;
  }
  pictureSize(buffer) {
    try {
      // Check its dimensions using image-size
      const dimensions = imageSize(buffer);
      if (dimensions && dimensions.width && dimensions.height) {
        console.log('Dimensions:', dimensions.width, 'x', dimensions.height);
        return [dimensions.width, dimensions.height];
      }
    } catch (error) {
      // Handle file read errors or invalid image dimensions
      console.error('Error:', error.message);
    }
    console.log('Not a valid JPEG image');
    return null;
  }

*/
  async init() {
    const operation = retry.operation();
    return new Promise(async (resolve, reject) => { // brake out or continue 
      operation.attempt(async (currentAttempt) => { // loop
        try {

          // Acquire a connection from the pool
          this.client = await this.pool.getConnection();
          await this.client.query('USE broccoli');

          // Start, read stores.json and insert test data
          try
          {
            let data = await fs.readFile('./users.json', 'utf8');
            this.users = JSON.parse(data);

            for (const user of this.users)
            {
              const picture = await fs.readFile(user.picturePath, { encoding: null, flag: 'r' });
              //const size =  await pictureSize(picture);
              try {
                // Your code that might throw an error, such as a database query
                await this.client.query('CALL insertUser(?, ?, ?)', [
                  user.username,
                  user.password,
                  picture,
                ]);
                // Continue with your code if there is no error
              } catch (error) {
                // Handle the error here
                if (error.code === 'ER_SIGNAL_EXCEPTION' && error.sqlMessage === 'Username already exists.') {
                  console.error('Username already exists.');
                } else {
                  // Handle other types of errors
                  console.error('Error during recipe insertion:', error);
                }
              }
            }
            data = await fs.readFile('./stores.json', 'utf8');
            this.stores = JSON.parse(data);

            for (const store of this.stores)
            {
              await this.client.query('CALL insertStore(?, ?, ?)', [
                store.name,
                store.url,
                store.district,
              ]);
            }

            data = await fs.readFile('./recipes.json', 'utf8');
            this.recipes = JSON.parse(data);

            for (const recipe of this.recipes)
            {
              let body = "";
              const size = recipe.bodyParagrps.length;
              console.log(size);

              for (let i = 0; i < size; i++)
              {
                body+=recipe.bodyParagrps[i]+";";
              }
              const pictureData = await fs.readFile(recipe.picturePath, { encoding: null, flag: 'r' });
              // Add the recipe
              try {
                const [recipeResult] = await this.client.execute('CALL insertRecipe(?, ?, ?, ?, ?)', [
                  recipe.userId,
                  recipe.name,
                  pictureData,
                  recipe.time,
                  body
                ]);

                console.log('Recipe Result:', recipeResult);

                const recipeId = recipeResult[0][0].recipeId;
                
                for (const innerLoop of recipe.items)
                {
                  const dishTitle = innerLoop[0];
                  if (typeof dishTitle === "string")
                  {
                    const slicedInnerLoop = innerLoop.slice(1);
                    for (const item of slicedInnerLoop)
                    {
                      await this.client.execute('CALL addIngredientToRecipe(?, ?, ?, ?, ?, ?)', [
                        item.name,
                        dishTitle,
                        recipeId,
                        item.quantity,
                        item.unit,
                        item.variant
                      ]);
                    }
                  }
                }

              } catch (error) {
                console.error('Error executing insertRecipe stored procedure:', error);
              }
            }

            // End
            this.client.release();
            resolve(); // Resolve the main Promise after successful setup
          }
          catch (error)
          {
            console.error('Error reading stores.json or calling stored procedure:', error);
            this.client.release();
            reject(error);
          }
        }
        catch (error)
        {
          console.log(`Connecting to MySQL (attempt ${currentAttempt}):`, error.message);
          if (operation.retry(error))
          {
            return;
          }
          reject(operation.mainError());
        }
      });
    });
  }
  async getAllStores() {
    const [rows] = await this.client.execute('SELECT * FROM store');
    return rows;
  }
}

module.exports = new Model();
