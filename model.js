const mysql = require('mysql2/promise');
const fs = require('fs').promises;
const retry = require('retry');

class Model {
  constructor() {
    this.stores = []; // Initialize stores as an empty array
  }

  async init() {
    const operation = retry.operation();
    return new Promise(async (resolve, reject) => {
      operation.attempt(async (currentAttempt) => {
        try {
          this.client = await mysql.createConnection({
            user: 'veganburger',
            host: 'db',
            database: 'broccoli',
            password: 'tofu',
            port: 3306,
          });
          await this.client.connect();

          // Read stores.json and insert data
          try {
            const data = await fs.readFile('./stores.json', 'utf8');
            this.stores = JSON.parse(data);

            for (const store of this.stores) {
              await this.client.execute('CALL insertStore(?, ?, ?)', [
                store.name,
                store.url,
                store.district,
              ]);
            }

            resolve(); // Resolve the main Promise after successful setup
          } catch (error) {
            console.error('Error reading stores.json or calling stored procedure:', error);
            reject(error);
          }
        } catch (error) {
          console.log(`Connecting to MySQL (attempt ${currentAttempt}):`, error.message);
          if (operation.retry(error)) {
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

