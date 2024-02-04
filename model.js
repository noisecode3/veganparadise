const mysql = require('mysql2/promise');
const fs = require('fs').promises;
const retry = require('retry');

class Model {
  constructor() {
    this.stores = []; // Initialize stores as an empty array
  }

  async init() {
    const operation = retry.operation();

    return new Promise((resolve, reject) => {
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
          resolve();
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

  async setup() {
    // Read stores.json and set this.stores
    try {
      const data = await fs.readFile('./stores.json', 'utf8');
      this.stores = JSON.parse(data);
    } catch (error) {
      console.error('Error reading stores.json:', error);
      this.stores = [];
    }

    for (const store of this.stores) {
      const [rows] = await this.client.execute(`
        SELECT * FROM store
        WHERE name = ?
        LIMIT 1
      `, [store.name]);

      if (rows.length === 0) {
        await this.client.execute(`
          INSERT INTO store (name, url, district)
          VALUES (?, ?, ?)
        `, [store.name, store.url, store.district]);
      }
    }

  }

  async getAllStores() {
    const [rows] = await this.client.execute('SELECT * FROM stores');
    return rows;
  }
}

module.exports = new Model();

