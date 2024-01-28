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
            user: 'read_only_user',
            host: 'db',
            database: 'broccoli',
            password: 'read_only_password',
            port: 3306,
          });

          await this.client.connect();
          resolve();
        } catch (error) {
          console.error(`Error connecting to MySQL (attempt ${currentAttempt}):`, error.message);

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
    /*

    // Database setup logic
    await this.client.query(`
      CREATE TABLE IF NOT EXISTS stores
      (
          id SERIAL NOT NULL,
          name VARCHAR(255),
          url VARCHAR(255),
          district VARCHAR(255),
          PRIMARY KEY (id)
      );
    `);

    for (const store of this.stores) {
      const [rows] = await this.client.execute(`
        SELECT * FROM stores
        WHERE name = ?
        LIMIT 1
      `, [store.name]);

      console.log(rows);

      if (rows.length === 0) {
        await this.client.execute(`
          INSERT INTO stores (name, url, district)
          VALUES (?, ?, ?)
        `, [store.name, store.url, store.district]);
      }
    }

  */
  }

  async getAllStores() {
    const [rows] = await this.client.execute('SELECT * FROM stores');
    return rows;
  }
}

module.exports = new Model();

