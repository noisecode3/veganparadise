// userModel.js

// In-memory storage for user data (replace this with a database in a real-world scenario)
const users = [];

// Function to get all users
function getAllUsers() {
  return users;
}

// Function to add a new user
function addUser(user) {
  users.push(user);
}

// Export the functions to be used in other parts of your application
module.exports = {
  getAllUsers,
  addUser,
};

