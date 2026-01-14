const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/auth');

// 내 프로필 조회 - 로그인 필수
router.get('/me', authMiddleware ,userController.updateMe);

// 내 트윗 조회 - 로그인 필수
router.get('/me/tweets', authMiddleware, userController.getMyTweets);

module.exports = router;