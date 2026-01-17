import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';

class CommentController extends GetxController {
  final int tweetId;
  final CommentService _service;

  CommentController({
    required this.tweetId,
    required CommentService service,
  }) : _service = service;

  final RxList<Comment> comments = <Comment>[].obs;
  final RxBool isLoading = false.obs;

  // 입력 상태
  final RxString draft = ''.obs;

  String get _myUsername {
    final auth = Get.find<AuthController>();
    return (auth.user.value?.username ?? '').trim();
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final data = await _service.getComments(tweetId);

      // 서버가 isMine을 안 내려주는 경우 대비: username 비교로 보정
      final my = _myUsername;
      final patched = data.map((c) {
        if (c.isMine) return c;
        if (my.isEmpty) return c;
        return c.copyWith(isMine: c.authorUsername == my);
      }).toList();

      // 최신순(원하면 바꿔도 됨)
      patched.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      comments.assignAll(patched);
    } catch (e) {
      Get.snackbar('오류', '댓글을 불러올 수 없습니다.\n$e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> add() async {
    final text = draft.value.trim();
    if (text.isEmpty) return;

    try {
      await _service.addComment(tweetId: tweetId, content: text);
      draft.value = '';
      await load();
    } catch (e) {
      Get.snackbar('오류', '댓글 작성 실패\n$e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> delete(int commentId) async {
    try {
      await _service.deleteComment(tweetId: tweetId, commentId: commentId);
      await load();
    } catch (e) {
      Get.snackbar('오류', '댓글 삭제 실패\n$e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
