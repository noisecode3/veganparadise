const express = require('express');
const csurf = require('@dr.pogodin/csurf');
const path = require('path');
const session = require('express-session');
const model = require('./model');
const view = require('./view');
const controller = require('./controller');

process.execArgv = process.execArgv.filter(arg => !arg.includes('inspect'));
process.execArgv.push(`--inspect=9230`);

const app = express();
const PORT = process.env.PORT || 3000;

// Enable ejs and set views dir
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Enable sessions
app.use(session({ secret: 'your-secret-key', resave: false, saveUninitialized: false }));

// Enable csurf protection after session
app.use(csurf());

// Add the csrf token to all responses
app.use((req, res, next) => {
  res.locals.csrfToken = req.csrfToken();
  next();
});

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(express.static(path.join(__dirname, './public')));

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something went wrong!');
});

model.init()
  .then(() => {
    app.get('/', (req, res) => {
      res.sendFile(path.join(__dirname, './public/index.html'));
    });
    
    app.use('/', view);
    app.use('/', controller);

    // Catch-all route for serving other files from "public"
    app.get('*', (req, res) => {
      res.sendFile(path.join(__dirname, './public', req.url));
    });

    app.listen(PORT, '0.0.0.0', () => {
      console.log(`Server is running on port ${PORT}`);
    });
  })
  .catch((error) => {
    console.error('Error during setup:', error.message);
    process.exit(1); // Exit the process if setup fails
  });

