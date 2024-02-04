const express = require('express');
const router = express.Router();
const userModel = require('./userModel');
const model = require('./model');

// Define a simple route
router.get('/hello', (req, res) => {
  res.json({ message: 'Hello, broccoli API!' });
});

// Example protected route that requires authentication
router.get('/dashboard', (req, res) => {
  // Check if the user is authenticated by checking the session
  if (req.session.username) {
    res.send(`Welcome to the dashboard, ${req.session.username}!`);
  } else {
    res.redirect('/login'); // Redirect to the login page if not authenticated
  }
});

router.get('/users', (req, res) => {
  const users = userModel.getAllUsers();
  res.render('users', { users }); // Assume a template engine
});

router.get('/store=:storename', function (req, res) {
  const { storename } = req.params;
  console.log(storename);
  const index = model.stores.findIndex(store => store.name === storename);
  if (index > -1) {
    res.json(model.stores[index]);
  } else {
    res.send('Store not found!');
  }
});

module.exports = router;

