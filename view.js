const express = require('express');
const router = express.Router();
const userModel = require('./userModel');
const model = require('./model');

// Define a simple route
router.get('/hello', (req, res) => {
  res.json({ message: 'Hello, broccoli API!' });
});

router.get('/users', (req, res) => {
  const users = userModel.getAllUsers();
  res.render('users', { users }); // Assume a template engine
});

router.get('/:storename', function (req, res) {
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

