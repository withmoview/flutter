const pool = require('../config/db');
// 전체 트윗 조회 (타임라인) - 페이징 지원
exports.findAll = async (currentUserId = null, page = 1, limit = 20) => {
    const offset = (page - 1) * limit;
    const query = `
    SELECT
    t.*,
    u.name,
    u.username,
    u.profile_image_id,
    (SELECT COUNT(*) FROM likes WHERE tweet_id = t.id) as like_count,
    ${currentUserId? '(SELECT COUNT(*) FROM likes WHERE tweet_id = t.id AND user_id = ?) as is_liked': '0 as is_liked'}
    FROM tweets t
    JOIN users u ON t.user_id = u.id
    ORDER BY t.created_at DESC
    LIMIT ? OFFSET ?
    `;
const params = currentUserId
    ? [currentUserId, String(limit), String(offset)]
    : [String(limit), String(offset)];
const [rows] = await pool.execute(query, params);
return rows;
};

// 전체 트윗 수 조회 (페이징용)
exports.countAll = async () => {
const [rows] = await pool.execute('SELECT COUNT(*) as total FROM tweets');
    return rows[0].total;
};

// 트윗 생성
exports.create = async (userId, content, imageId = null) => {
const [result] = await pool.execute(
    'INSERT INTO tweets (user_id, content, image_id) VALUES (?, ?, ?)',
    [userId, content, imageId]
    );
    return result.insertId;
};

// ID로 트윗 조회
exports.findById = async (id) => {
    const [rows] = await pool.execute(
    'SELECT * FROM tweets WHERE id = ?',
    [id]
    );
return rows[0];
};

// 트윗 삭제
exports.delete = async (id) => {
    await pool.execute('DELETE FROM tweets WHERE id = ?', [id]);
};

// 사용자의 트윗 조회
exports.findByUserId = async (userId, currentUserId = null) => {
const query = `
    SELECT
    t.*,
    u.name,
    u.username,
    u.profile_image_id,
    (SELECT COUNT(*) FROM likes WHERE tweet_id = t.id) as
    like_count, 
    ${currentUserId ? '(SELECT COUNT(*) FROM likes WHERE tweet_id = t.id AND user_id = ?) as is_liked' : '0 as is_liked'}
    FROM tweets t
    JOIN users u ON t.user_id = u.id
    WHERE t.user_id = ?
    ORDER BY t.created_at DESC`;
    const params = currentUserId ? [currentUserId, userId] : [userId];
    const [rows] = await pool.execute(query, params);
    return rows;
};