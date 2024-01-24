const express = require('express');
const mysql = require('mysql2');
const app = express();
const PORT = process.env.PORT || 3000;

const stores = require('./stores.json')


const connectToDatabase = () => {
  const connection = mysql.createConnection({
    host: 'db', // Use the service name of your MySQL container
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DATABASE,
  });

  connection.connect((err) => {
    if (err) {
      console.error('Error connecting to database:', err);
      // Retry connection after 3 seconds
      setTimeout(connectToDatabase, 3000);
    } else {
      console.log('Connected to database');

      // Perform your database operations here

      // Close the connection after your operations
      connection.end();
    }
  });
};

// Start the initial connection attempt
connectToDatabase();





const connection = mysql.createConnection({
  host: 'db',
  user: process.env.MYSQL_USER,
  password: process.env.MYSQL_PASSWORD,
  database: process.env.MYSQL_DATABASE,
});

connection.connect((err) => {
  if (err) {
    console.error('Error connecting to MySQL:', err);
  } else {
    console.log('Connected to MySQL');
  }
});




// Example model
class UserModel {
  constructor() {
    this.users = [];
  }

  addUser(user) {
    this.users.push(user);
  }

  getAllUsers() {
    return this.users;
  }
}

// Create an instance of the model
const userModel = new UserModel();


// Example view
app.get('/users', (req, res) => {
  const users = userModel.getAllUsers();
  res.render('users', { users }); // Assume a template engine
});


// Example controller
app.post('/users', (req, res) => {
  const { username } = req.body;

  // Validate the input (controller responsibility)
  if (!username) {
    return res.status(400).send('Username is required');
  }

  // Update the model
  userModel.addUser({ username });

  // Redirect or respond as appropriate
  res.redirect('/users');
});

app.get('/:storename', function (req, res) {
  const { storename } = req.params;
  console.log(storename);
  const index = stores.findIndex(store => store.name === storename);
  if (index > -1) {
    res.json(stores[index]);
  } else {
    res.send('Store not found!');
  }
});


app.delete('/', function (req, res) {
  const { storename } = req.query
  console.log(storename)
  const index = stores.findIndex(store => store.name === storename)
  if (index > -1) {
    stores.splice(index, 1)
    res.send(`Store found! Deleting store with index: ${index}`)
  } else {
    res.send('Store not found!')
  }
})

app.post('/',
  express.json(),
  (req, res) => {
    try {
      const { body } = req;

      if (!body || Object.keys(body).length === 0) {
        // If the request body is empty or does not contain valid data
        res.status(400).send('Invalid or empty request body');
        return;
      }

      console.log(body);

      stores.push(body);
      res.send('Store added!');
    } catch (error) {
      console.error(error);
      res.status(500).send('Internal Server Error');
    }
  }
);

// Define a simple route
app.get('/hello', (req, res) => {
  res.json({ message: 'Hello, broccoli API!' });
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
