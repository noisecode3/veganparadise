const express = require('express');
const router = express.Router();
const userModel = require('./userModel');
const model = require('./model');

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
