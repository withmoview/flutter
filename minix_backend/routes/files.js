const express = require('express');
const router = express.Router();
const fileController = require('../controllers/fileController');
const authMiddleware = require('../middleware/auth');
const upload = require('../config/multer');

// 파일 업로드 - 인증 필수
router.post('/', authMiddleware, upload.single('file'),
fileController.uploadFile);

// 파일 조회 - 인증 불필요 (이미지 표시용)
router.get('/:id', fileController.getFile);
module.exports = router;