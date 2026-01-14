const pool = require('../config/db');
// 파일 정보 저장
exports.create = async (filename, originalName,
mimetype, size, userId) => {
const [result] = await pool.execute(
 'INSERT INTO files (filename, original_name, mimetype, size, user_id) VALUES (?, ?, ?, ?, ?)',
 [filename, originalName, mimetype, size, userId]
 );
return result.insertId;
};

// ID로 파일 조회
exports.findById = async (id) => {
const [rows] = await pool.execute(
 'SELECT * FROM files WHERE id = ?',
 [id]
 );
return rows[0];
};