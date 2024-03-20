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

/*

CREATE PROCEDURE getRecipeList()
BEGIN
  SELECT id, name, picture FROM recipe;
END //

*/

// Set EJS as the view engine
// Define a route to handle the GET request
router.get('/menu.html', async (req, res) => {
  try {
    // Acquire a connection from the pool
    const client = await model.pool.getConnection();
    const [list] = await client.execute('CALL getRecipeList()');
    console.log(list[0]);
    res.render('menu', { pictureCards: list[0] });
    client.release();
  }
  catch (error)
  {

    res.status(500).send('Internal Server Error');
    client.release();
    console.log('${error.message}');
  }
});

// Define a route to handle image requests


router.get('/image/:id', async (req, res) => {
  const pictureId = parseInt(req.params.id, 10);
  const client = await model.pool.getConnection();
  const [result] = await client.execute('CALL getPicture(?)', [pictureId]);
  res.setHeader('Content-Disposition', 'attachment; filename= req.params.id +".jpg"');
  res.contentType('result[0][0].fileType');
  res.end(result[0][0].data, 'binary');
  client.release();
});




router.get('/recipe_:id.html', async (req, res) => {
    const recipeId = parseInt(req.params.id, 10);
    const client = await model.pool.getConnection();
    const [result] = await client.execute('CALL getRecipe(?)', [recipeId]);
    const recipeData = result[0][0];
    const ingredientsData = result[1];

    // Check if there's data
    if (!recipeData) {
        res.status(404).send('Recipe not found');
        return;
    }

    console.log(recipeData);
    console.log(ingredientsData);

    res.render('recipe', { recipe: recipeData, ingredients: ingredientsData });
    client.release();
});


/*
router.get('/recipe/:id', async (req, res) => {
  const recipeId = parseInt(req.params.id, 10);
  const client = await model.pool.getConnection();
  const [result] = await client.execute('CALL getRecipe(?)', [recipeId]);
  console.log(result[0][0]);
  res.render('recipe', { recipe: result[0][0] });
  client.release();
});
*/

module.exports = router;

