require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// Import routes
const syncRoutes = require('./routes/sync');
const userRoutes = require('./routes/user');

// Use routes
app.use('/api/sync', syncRoutes);
app.use('/api/user', userRoutes);

// Database connection
const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/aegis';

app.get('/ping', (req, res) => {
  res.json({ message: 'pong', status: 'ok' });
});

mongoose.connect(MONGO_URI)
  .then(() => {
    console.log('Connected to MongoDB');
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  })
  .catch(err => {
    console.error('Database connection error:', err);
  });
