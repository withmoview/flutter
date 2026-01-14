const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const tweetRoutes = require('./routes/tweets');
const userRoutes = require('./routes/users');
const fileRoutes = require('./routes/files')

const app = express();

// 미들웨어
app.use(cors());
app.use(express.json());

// 라우트 연결
app.use('/api/auth', authRoutes);
app.use('/api/tweets', tweetRoutes);
app.use('/api/users', userRoutes);
app.use('/api/files', fileRoutes);

// Health check
app.get('/', (req, res) => {
    res.json({ message: 'Mini X API Server' });
});

module.exports = app;