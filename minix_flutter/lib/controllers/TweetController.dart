import 'dart:io';

import 'package:get/get.dart';
import '../models/tweet.dart';
import '../services/api_service.dart';

class TweetController extends GetxController {
  final _api = Get.find<ApiService>();

  final RxList<Tweet> tweets = <Tweet>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTimeline();
  }

  Future<void> loadTimeline() async {
    isLoading.value = true;

    try {
      final data = await _api.getTimeline();
      // data가 List<dynamic> 가정
      tweets.value = data
          .map((e) => Tweet.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      Get.snackbar('오류', '타임라인을 불러올 수 없습니다.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createTweet(String content) async {
    if (content.trim().isEmpty) return false;

    try {
      final res = await _api.createTweet(content);
      if (res.statusCode == 201 || res.statusCode == 200) {
        await loadTimeline();
        return true;
      }
    } catch (e) {
      Get.snackbar('오류', '트윗 작성 실패');
    }
    return false;
  }

  Future<void> deleteTweet(int id) async {
    try {
      final success = await _api.deleteTweet(id);

      if (success) {
        tweets.removeWhere((t) => t.id == id);
        tweets.refresh();
        Get.snackbar('완료', '트윗이 삭제되었습니다');
      }
    } catch (e) {
      Get.snackbar('오류', '삭제 실패');
    }
  }

  /// ✅ 좋아요 토글: UI 즉시 반영 + 서버 응답으로 동기화 + 실패 시 원복
  Future<void> toggleLike(int tweetId) async {
    final idx = tweets.indexWhere((t) => t.id == tweetId);
    if (idx == -1) return;

    final before = tweets[idx];

    // 1) 낙관적 업데이트 (즉시 반영)
    final optimisticLiked = !before.isLiked;
    final optimisticCount =
        (before.likeCount + (optimisticLiked ? 1 : -1)).clamp(0, 1 << 30);

    tweets[idx] = before.copyWith(
      isLiked: optimisticLiked,
      likeCount: optimisticCount,
    );
    tweets.refresh();

    try {
      final result = await _api.toggleLike(tweetId);
      if (result == null) return;

      // 2) 서버 응답 키 다양하게 대응
      final likedVal = result['liked'] ?? result['is_liked'] ?? result['isLiked'];
      final countVal = result['like_count'] ?? result['likeCount'];

      final bool liked = likedVal is bool
          ? likedVal
          : (likedVal is num ? likedVal == 1 : optimisticLiked);

      final int likeCount = countVal is int
          ? countVal
          : int.tryParse((countVal ?? optimisticCount).toString()) ??
              optimisticCount;

      // 3) 최종 동기화
      tweets[idx] = tweets[idx].copyWith(
        isLiked: liked,
        likeCount: likeCount,
      );
      tweets.refresh();
    } catch (e) {
      // 4) 실패하면 원복
      tweets[idx] = before;
      tweets.refresh();
      Get.snackbar('오류', '좋아요 실패');
    }
  }

  // -------------------------
  // 리뷰 생성 (트윗 content로 패킹해서 올림)
  // -------------------------
  Future<bool> createReview({
    required String title,
    required String genre,
    required double rating,
    required String content,
    String? posterUrl,
    int? tmdbId,
    File? posterFile, // 현재는 서버 업로드 안 함 (UI 미리보기용)
  }) async {
    final packed = _packReview(
      title: title,
      genre: genre,
      rating: rating,
      text: content,
      posterUrl: posterUrl,
      tmdbId: tmdbId,
    );

    return await createTweet(packed);
  }

  String _packReview({
    required String title,
    required String genre,
    required double rating,
    required String text,
    String? posterUrl,
    int? tmdbId,
  }) {
    final lines = <String>[
      '[REVIEW]',
      'TITLE=${title.trim()}',
      'GENRE=${genre.trim()}',
      'RATING=${rating.toStringAsFixed(1)}',
      if (tmdbId != null) 'TMDB_ID=$tmdbId',
      if (posterUrl != null && posterUrl.trim().isNotEmpty)
        'POSTER=${posterUrl.trim()}',
      'TEXT=${text.trim()}',
    ];

    return lines.join('\n');
  }
}
