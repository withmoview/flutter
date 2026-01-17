import 'dart:io';
import 'package:get/get.dart';
import '../models/review.dart';
import '../services/api_service.dart';
/*
class ReviewController extends GetxController {
  final _api = Get.find<ApiService>();

  final RxList<Review> reviews = <Review>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTimeline();
  }

  Future<void> loadTimeline() async {
    isLoading.value = true;
    try {
      final data = await _api.getReviewsTimeline();
      reviews.value = data.map((e) => Review.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      Get.snackbar('오류', '리뷰를 불러올 수 없습니다.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createReview({
    required String title,
    required String genre,
    required String content,
    required double rating,
    File? posterFile,
  }) async {
    if (title.trim().isEmpty) return false;
    if (content.trim().isEmpty) return false;
    if (rating <= 0) return false;

    try {
      final res = await _api.createReview(
        title: title,
        genre: genre,
        content: content,
        rating: rating,
        posterFile: posterFile,
      );

      if (res.statusCode == 201) {
        await loadTimeline();
        return true;
      }
    } catch (e) {
      Get.snackbar('오류', '리뷰 작성 실패');
    }
    return false;
  }

  Future<void> deleteReview(int id) async {
    try {
      final success = await _api.deleteReview(id);
      if (success) {
        reviews.removeWhere((r) => r.id == id);
        Get.snackbar('완료', '리뷰가 삭제되었습니다');
      }
    } catch (e) {
      Get.snackbar('오류', '삭제 실패');
    }
  }

  Future<void> toggleLike(int reviewId) async {
    try {
      final result = await _api.toggleReviewLike(reviewId);
      if (result != null) {
        final index = reviews.indexWhere((r) => r.id == reviewId);
        if (index != -1) {
          reviews[index] = reviews[index].copyWith(
            isLiked: result['liked'],
            likeCount: result['like_count'],
          );
        }
      }
    } catch (e) {
      Get.snackbar('오류', '좋아요 실패');
    }
  }
}
*/