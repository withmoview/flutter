// routes/tweets.js
const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const tweetController = require('../controllers/tweetController');
const authMiddleware = require('../middleware/auth');
// 전체 트윗 조회 (타임라인) - 비로그인도 가능
router.get('/', (req, res, next) => {
// 토큰이 있으면 파싱, 없어도 통과
const authHeader = req.headers.authorization;
if (authHeader && authHeader.startsWith('Bearer ')) {
    const token = authHeader.split(' ')[1];
    try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    } catch (err) {
    // 토큰 유효하지 않으면 무시
    }
 }

next();

}, tweetController.getAllTweets);

// 트윗 작성 - 로그인 필수
router.post('/', authMiddleware, tweetController.createTweet);

// 트윗 삭제 - 로그인 필수
router.delete('/:id', authMiddleware, tweetController.deleteTweet);

// 좋아요 토글 - 로그인 필수
router.post('/:id/like', authMiddleware, tweetController.toggleLike);
module.exports = router;