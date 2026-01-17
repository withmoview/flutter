import 'package:get/get.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';

class CommentController extends GetxController {
  final int tweetId;
  final CommentService _service; // ✅ 인터페이스 타입

  CommentController({
    required this.tweetId,
    required CommentService service,
  }) : _service = service;

  final RxList<Comment> comments = <Comment>[].obs;
  final RxBool isLoading = false.obs;

  // 입력 상태
  final RxString draft = ''.obs;

  // 작성자(나중에 서버 붙이면 로그인 유저 정보로 교체)
  String authorName = 'Me';
  String authorUsername = 'me';

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final data = await _service.getComments(tweetId);
      comments.assignAll(data);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> add() async {
    final text = draft.value.trim();
    if (text.isEmpty) return;

    await _service.addComment(
      tweetId: tweetId,
      content: text,
      authorName: authorName,
      authorUsername: authorUsername,
      isMine: true,
    );

    draft.value = '';
    await load();
  }

  Future<void> delete(int commentId) async {
    await _service.deleteComment(tweetId: tweetId, commentId: commentId);
    await load();
  }
}
