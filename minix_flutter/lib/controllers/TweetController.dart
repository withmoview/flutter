import 'package:get/get.dart';
import '../models/tweet.dart';
import '../services/api_service.dart';

import 'dart:io'; // 맨 위에 추가

class TweetController extends GetxController{
  final _api = Get.find<ApiService>();

  final RxList<Tweet> tweets = <Tweet>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit(){
    super.onInit();
    loadTimeline();
  }

  Future<void> loadTimeline() async{
    isLoading.value = true;

    try{
      final data = await _api.getTimeline();

      tweets.value = data.map((json)=> Tweet.fromJson(json)).toList();
    }catch(e){
      Get.snackbar('오류', '타임라인을 불러올 수 없습니다.');
    }finally {
      isLoading.value = false;
    }
  }

  Future<bool> createTweet(String content) async{
    if(content.trim().isEmpty) return false;

    try{
      final res = await _api.createTweet(content);
      if(res.statusCode == 201){
        await loadTimeline();

        return true;
      }
    }catch(e){
      Get.snackbar('오류', '트윗 작성 실패');
    }
    return false;
  }

  Future<void> deleteTweet(int id) async{
    try{
      final succes = await _api.deleteTweet(id);

      if(succes){
        tweets.removeWhere((t)=> t.id == id);
        Get.snackbar('완료', '트윗이 삭제되었습니다');
      }
    } catch(e){
        Get.snackbar('오류', '삭제 실패');
    }
  }

  Future<void> toggleLike(int tweetId) async{
    try{
      final result = await _api.toggleLike(tweetId);

      if(result != null){
        final index = tweets.indexWhere((t)=> t.id == tweetId);
        if(index != -1){
          tweets[index] = tweets[index].copyWith(
            isLiked: result['liked'],
            likeCount: result['like_count'],
          );
        }
      }
    } catch(e){
      Get.snackbar('오류', '좋아요 실패');
    }
  }


//리뷰 생성
Future<bool> createReview({
  required String title,
  required String genre,
  required double rating,
  required String content,
  String? posterUrl,   // ✅ 추가
  int? tmdbId,         // (선택) 나중에 확장용
  File? posterFile, // 지금은 서버 저장 안 함 (UI 미리보기용)
}) async {
  final packed = _packReview(
    title: title,
    genre: genre,
    rating: rating,
    posterUrl: posterUrl,
    tmdbId: tmdbId,
    text: content,
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
  // 줄바꿈 포함해도 안전하게 저장되도록 TEXT는 마지막에 둠
  return [
    '[REVIEW]',
    'TITLE=${title.trim()}',
    'GENRE=${genre.trim()}',
    'RATING=${rating.toStringAsFixed(1)}',
    'TEXT=${text.trim()}',
    if (tmdbId != null) 'TMDB_ID=$tmdbId',        //영화추가
    if (posterUrl != null && posterUrl.trim().isNotEmpty) 'POSTER=${posterUrl.trim()}', //영화추가
  ].join('\n');
}

}

