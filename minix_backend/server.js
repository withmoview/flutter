const app = require('./app');

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`서버 실행: http://localhost:${PORT}`);
});












// require('dotenv').config();
// const express = require('express');
// const cors = require('cors');

// const app = express();

// // 임시 유저 저장소 (나중에 DB로 교체)
// const users = [];
// let userIdCounter = 1;

// const auth = (req, res, next) => {
// const authHeader = req.headers.authorization;
// if (!authHeader || !authHeader.startsWith('Bearer ')) {
//     return res.status(401).json({ message: '토큰이 없습니다' });
//  }
// const token = authHeader.split(' ')[1];
// try {
//     const decoded = jwt.verify(token, process.env.JWT_SECRET);
//     req.user = decoded; // 이후 라우트에서 사용
//     next();
// } catch (error) {
//     return res.status(401).json({ message: '유효하지 않은 토큰' });
//     }
// };

// // GET /api/users/me (인증 필수)
// app.get('/api/users/me', auth, (req, res) => {
//   const user = users.find(u => u.id === req.user.id);
//   if (!user) {
//     return res.status(404).json({ message: '사용자를 찾을 수 없습니다'
//     });
//     }
//     // 비밀번호 제외하고 반환
//     const { password, ...userWithoutPassword } = user;
//         res.json({ data: userWithoutPassword });
// });

// app.use(cors());
// app.use(express.json());
// // 테스트 API
// app.get('/', (req, res) => {
// res.json({ message: 'Mini X API' });
// });
// // 서버 시작
// const PORT = process.env.PORT || 3000;
// app.listen(PORT, () => {
// console.log(`서버 실행: http:=/localhost:${PORT}`);
// });

// // Query String: GET /search?q=flutter
// app.get('/search', (req, res) => {
// const keyword = req.query.q;
// res.json({ keyword: keyword });
// });
// // URL Parameter: GET /tweets/42
// app.get('/tweets/:id', (req, res) => {
// const tweetId = req.params.id;
// res.json({ tweetId: tweetId });
// });
// // Body: POST /echo
// app.post('/echo', (req, res) => {
// const data = req.body;
// res.json({ received: data });
// });

// const bcrypt = require('bcrypt');
// // POST /api/auth/register
// app.post('/api/auth/register', async (req, res) => {
// try {
//  const { email, password, name, username } = req.body;
//  // 이메일 중복 체크
//  const existing = users.find(u => u.email === email);
//  if (existing) {
//  return res.status(400).json({ message: '이미 가입된 이메일입니다' });
//  }
//  // 비밀번호 해싱 (3교시에 자세히!)
//  const hashedPassword = await bcrypt.hash(password, 10);
//  // 유저 생성
//  const newUser = {
//  id: userIdCounter++,
//  email, password: hashedPassword, name, username
//  };
//  users.push(newUser);
//  res.status(201).json({ message: '회원가입 성공', userId:
// newUser.id });
//  } catch (error) {
//  res.status(500).json({ message: '서버 오류' });
//  }
// });

// const jwt = require('jsonwebtoken');
// // POST /api/auth/login
// app.post('/api/auth/login', async (req, res) => {
// try {
//  const { email, password } = req.body;
//  // 유저 찾기
//  const user = users.find(u => u.email === email);
//  if (!user) {
//  return res.status(401).json({ message: '이메일 또는 비밀번호가 올바르지 않습니다' });
//  }
//  // 비밀번호 검증
//  const isMatch = await bcrypt.compare(password, user.password);
//  if (!isMatch) {
//  return res.status(401).json({ message: '이메일 또는 비밀번호가 올바르지 않습니다' });
//  }
//  // JWT 발급
//  const token = jwt.sign(
//  { id: user.id, email: user.email, username: user.username },
//  process.env.JWT_SECRET,
//  { expiresIn: '7d' }
//  );
//  res.json({
//  message: '로그인 성공',
//  token,
//  user: { id: user.id, email: user.email, name: user.name,
// username: user.username }
//  });
//  } catch (error) {
//  res.status(500).json({ message: '서버 오류' });
//  }
// });

