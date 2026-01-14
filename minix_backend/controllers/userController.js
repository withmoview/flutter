const userModel = require('../models/userModel');
const tweetModel = require('../models/tweetModel');
// 내 프로필 조회
exports.getMe = async (req, res) => {
try {
 const user = await userModel.findById(req.user.id);
 if (!user) {
 return res.status(404).json({ message: '사용자를 찾을 수 없습니다' });
 }
 res.json({ data: user });
 } catch (err) {
 console.error(err);
 res.status(500).json({ message: '서버 오류가 발생했습니다'
});
 }
};

// 내 트윗 조회
exports.getMyTweets = async (req, res) => {
try {
 const tweets = await tweetModel.findByUserId(req.user.id,
req.user.id);
 res.json({
 data: tweets.map(t => ({
 ...t,
 is_liked: !!t.is_liked
 }))
 });
 } catch (err) {
 console.error(err);
 res.status(500).json({ message: '서버 오류가 발생했습니다'
});
 }
};

// 프로필 수정
exports.updateMe = async (req, res) => {
try {
 const { name, profile_image_id } = req.body;
 // 변경할 필드만 업데이트
 const updates = [];
 const values = [];
 if (name) {
 updates.push('name = ?');
 values.push(name);
 }
 if (profile_image_id) {
 updates.push('profile_image_id = ?');
 values.push(profile_image_id);
 }
 if (updates.length === 0) {
 return res.status(400).json({ message: '변경할 내용이 없습니다'
});
 }
 values.push(req.user.id);
 await pool.execute(
 `UPDATE users SET ${updates.join(', ')} WHERE id = ?`,
 values
 );
 // 업데이트된 프로필 조회
 const user = await userModel.findById(req.user.id);
 res.json({ data: user });
 } catch (err) {
 console.error(err);
 res.status(500).json({ message: '프로필 수정 실패' });
 }
};