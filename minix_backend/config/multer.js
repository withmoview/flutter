const multer = require('multer');
const path = require('path');
const storage = multer.diskStorage({
destination: (req, file, cb) => {
 cb(null, 'uploads/'); // uploads 폴더에 저장
 },
filename: (req, file, cb) => {
 // 원본파일명_타임스탬프.확장자
 const ext = path.extname(file.originalname);
 const name = path.basename(file.originalname, ext);
 cb(null, `${name}_${Date.now()}${ext}`);
 }
});
const upload = multer({
storage,
limits: { fileSize: 5 * 1024 * 1024 }, // 5MB 제한
fileFilter: (req, file, cb) => {
 // 이미지 파일만 허용
 if (file.mimetype.startsWith('image/')) {
 cb(null, true);
 } else {
 cb(new Error('이미지 파일만 업로드 가능합니다'),
false);
 }
 }
});
module.exports = upload;