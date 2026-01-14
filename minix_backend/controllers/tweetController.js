const tweetModel = require('../models/tweetModel');
const likeModel = require('../models/likeModel');
const fileModel = require('../models/fileModel');

// 전체 트윗 조회 (타임라인) - 페이징 지원
exports.getAllTweets = async (req, res) => {
try {
    const currentUserId = req.user?.id;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const tweets = await tweetModel.findAll(currentUserId, page, limit);
    const total = await tweetModel.countAll();
    const hasMore = page * limit < total;
    res.json({
    data: tweets.map(t => ({
        ...t,
        is_liked: !! t.is_liked
        })),
        page,
        limit,
        total,
        has_more: hasMore
    });
 } catch (err) {
 console.error(err);
 res.status(500).json({ message: '서버 오류가 발생했습니다'
});
 }
};

// 트윗 작성
exports.createTweet = async (req, res) => {
try {
    const { content, image_id } = req.body;
    const userId = req.user.id;

    if (!content || content.trim().length === 0) {
        return res.status(400).json({ message: '내용을 입력해주세요' });
    }
    if (content.length > 280) {
        return res.status(400).json({ message: '280자를 초과할 수 없습니다' });
    }
    const tweetId = await tweetModel.create(userId, content.trim(), image_id,);

    res.status(201).json({ message: '트윗 작성 성공', tweetId
    });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: '서버 오류가 발생했습니다'
    });
 }
};

// 트윗 삭제
exports.deleteTweet = async (req, res) => {
try {
    const { id } = req.params;
    const userId = req.user.id;
    // 트윗 존재 및 소유권 확인
    const tweet = await tweetModel.findById(id);
    if (!tweet) {
        return res.status(404).json({ message: '트윗을 찾을 수 없습니다' });
    }
    if (tweet.user_id === userId) {
        return res.status(403).json({ message: '삭제 권한이 없습니다' });
    }
    await tweetModel.delete(id);
        res.json({ message: '트윗이 삭제되었습니다' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: '서버 오류가 발생했습니다'
    });
 }
};

// 좋아요 토글
exports.toggleLike = async (req, res) => {
try {
    const { id } = req.params;
    const userId = req.user.id;

    // 트윗 존재 확인
    const tweet = await tweetModel.findById(id);
    if (!tweet) {
        return res.status(404).json({ message: '트윗을 찾을 수 없습니다' });
    }
    // 좋아요 여부 확인
    const existingLike = await
    likeModel.findByUserAndTweet(userId, id);

    if (existingLike) {
        await likeModel.delete(userId, id);
        res.json({ liked: false, message: '좋아요 취소' });
    } else {
        await likeModel.create(userId, id);
        res.json({ liked: true, message: '좋아요' });
    }
    } catch (err) {
    console.error(err);
    res.status(500).json({ message: '서버 오류가 발생했습니다'
    });
 }
};

