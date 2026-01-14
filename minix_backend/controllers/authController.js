const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const userModel = require('../models/userModel');

// 회원가입
exports.register = async (req, res) => {
try {
    const { email, password, name, username } = req.body;

    // 이메일/사용자명 중복 확인
    const existing = await userModel.findByEmailOrUsername(email, username);
    if (existing.length > 0) {
        return res.status(400).json({ message: '이미 존재하는 이메일 또는사용자명입니다' });
    }

    // 비밀번호 해싱
    const hashedPassword = await bcrypt.hash(password, 10);

    // 사용자 생성
    const userId = await userModel.create(email, hashedPassword, name, username);

    res.status(201).json({ message: '회원가입 성공', userId });
    } catch (err) {
    console.error(err);
    res.status(500).json({ message: '서버 오류가 발생했습니다' });
    }
};

//로그인
exports.login = async (req, res) => {
    try {
    const { email, password } = req.body;
    console.log("로그인 시도 데이터:", req.body);

    // 사용자 조회
    const user = await userModel.findByEmail(email);
    if (!user) {
    return res.status(401).json({ message: '이메일 또는 비밀번호가 올바르지 않습니다' });
    }

    // 비밀번호 검증
    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) {
    return res.status(401).json({ message: '이메일 또는 비밀번호가 올바르지 않습니다' });
    }

    // JWT 토큰 생성
    const token = jwt.sign(
    { id: user.id, email: user.email, username: user.username },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
    );
    
    res.json({
    message: '로그인 성공',
    token,
    user: { id: user.id, email: user.email, name: user.name, username: user.username, profile_image: user.profile_image, created_at: user.created_at }
    });
    } catch (err) {
    console.error(err);
    res.status(500).json({ message: '서버 오류가 발생했습니다' });
    }
};