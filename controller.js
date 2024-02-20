const express = require('express');
const router = express.Router();
const userModel = require('./userModel');
const model = require('./model');

// Read the image file as binary data
//const profilePictureData = fs.readFileSync('path/to/profile-picture.jpg');

// Insert the data into the database
//connection.query('INSERT INTO users (username, profile_picture) VALUES (?, ?)', ['john_doe', profilePictureData], (error, results, fields) => {
//  if (error) throw error;
//  console.log('Profile picture inserted successfully');
//});


// Assuming you have a route for user login
router.post('/login', (req, res) => {
  const { username, password } = req.body;

  // Validate the username and password, and if valid, set the username in the session
  if (isValidLogin(username, password)) {
    req.session.username = username;
    res.send('Login successful');
  } else {
    res.send('Invalid credentials');
  }
});
function isValidLogin(username, password) {
  // Implement your validation logic here
  return true; // For demonstration purposes, always return true
}

router.post('/users', (req, res) => {
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

router.delete('/', function (req, res) {
  const { storename } = req.query
  console.log(storename)
  const index = model.stores.findIndex(store => store.name === storename)
  if (index > -1) {
    model.stores.splice(index, 1)
    res.send(`Store found! Deleting store with index: ${index}`)
  } else {
    res.send('Store not found!')
  }
})

router.post('/',
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

      model.stores.push(body);
      res.send('Store added!');
    } catch (error) {
      console.error(error);
      res.status(500).send('Internal Server Error');
    }
  }
);


module.exports = router;
