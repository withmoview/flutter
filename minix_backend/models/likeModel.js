const pool = require('../config/db');

// 좋아요 여부 확인
exports.findByUserAndTweet = async (userId, tweetId) => {
const [rows] = await pool.execute(
    'SELECT * FROM likes WHERE user_id = ? AND tweet_id = ?',
    [userId, tweetId]
    );
    return rows[0];
};

// 좋아요 추가
exports.create = async (userId, tweetId) => {
await pool.execute(
    'INSERT INTO likes (user_id, tweet_id) VALUES (?, ?)',
    [userId, tweetId]
    );
};

// 좋아요 삭제
exports.delete = async (userId, tweetId) => {
await pool.execute(
    'DELETE FROM likes WHERE user_id = ? AND tweet_id = ?',
    [userId, tweetId]
    );
};