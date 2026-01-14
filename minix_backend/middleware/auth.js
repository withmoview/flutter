const jwt = require('jsonwebtoken')

/* Bearer 로 가져온 jwt Token의 payload를 Decode 하여 성공하면 
req.user에 넣어주는 middleware*/
const authMiddleware = (req, res, next) => {
const authHeader = req.headers.authorization;

if (!authHeader || !authHeader.startsWith('Bearer ')) {
 return res.status(401).json({ message: '인증 토큰이 필요합니다' });
 }

const token = authHeader.split(' ')[1];

try {
 const decoded = jwt.verify(token, process.env.JWT_SECRET);
 req.user = decoded;
 next();
 } catch (err) {
 return res.status(401).json({ message: '유효하지 않은 토큰입니다'});
 }
};

module.exports = authMiddleware;