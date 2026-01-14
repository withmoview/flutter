const pool = require('../config/db');

// 이메일 또는 사용자명으로 사용자 조회
exports.findByEmailOrUsername = async (email, username) =>{
    const[rows] = await pool.execute(
        'SELECT id FROM users WHERE email = ? OR username = ?',
        [email, username]
    );
    return rows;
};

//이메일로 사용자 조회
exports.findByEmail = async (email) => {
    const [rows] = await pool.execute(
        'SELECT * FROM users WHERE email = ?',
        [email]
    );
    return rows[0];
};

// 사용자 생성
exports.create = async (email, hashedPassword, name, username) =>
{
const [result] = await pool.execute(
    'INSERT INTO users (email, password, name, username) VALUES (?,?,?,?)',
    [email, hashedPassword, name, username]
    );
    return result.insertId;
};

// ID로 사용자 조회
exports.findById = async (id) => {
    const [rows] = await pool.execute(
    'SELECT id, email, name, username, profile_image_id ,created_at FROM users WHEREid = ?',
    [id]
    );
    return rows[0];
};