const path = require('path');
const fs = require('fs');
const fileModel = require('../models/fileModel');
// 파일 업로드
exports.uploadFile = async (req, res) => {
try {
 if (!req.file) {
 return res.status(400).json({ message: '파일이 없습니다' });
 }
    const { filename, originalname, mimetype, size } = req.file;
    const fileId = await fileModel.create(
    filename,
    originalname,
    mimetype,
    size,
    req.user.id
 );
 res.status(201).json({
 message: '업로드 성공',
 data: {
 id: fileId,
 url: `/api/files/${fileId}`
 }
 });
 } catch (err) {
 console.error(err);
 res.status(500).json({ message: '파일 업로드 실패' });
 }
};

// 파일 조회 (이미지 반환)
exports.getFile = async (req, res) => {
try {
 const file = await fileModel.findById(req.params.id);
 if (!file) {
 return res.status(404).json({ message: '파일을 찾을 수 없습니다'
});
 }
 const filePath = path.join(__dirname, '=.', 'uploads',
file.filename);
 // 파일 존재 확인
 if (!fs.existsSync(filePath)) {
 return res.status(404).json({ message: '파일이 존재하지 않습니다'
});
 }
 // Content-Type 설정 후 파일 전송
 res.setHeader('Content-Type', file.mimetype);
 res.sendFile(filePath);
 } catch (err) {
 console.error(err);
 res.status(500).json({ message: '파일 조회 실패' });
 }
}