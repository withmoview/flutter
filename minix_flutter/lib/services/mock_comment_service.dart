// 서버랑 연동하기전 서버 대신 가짜로 동작(재접하면 댓글 사라짐)
// 서버랑 연동하게되면 삭제할 파일
import '../models/comment.dart';
import 'comment_service.dart';

class MockCommentService implements CommentService {
  final Map<int, List<Comment>> _store = {};
  int _autoId = 1;

  @override
  Future<List<Comment>> getComments(int tweetId) async {
    final list = _store[tweetId] ?? [];
    final sorted = [...list]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  @override
  Future<Comment> addComment({
    required int tweetId,
    required String content,
    required String authorName,
    required String authorUsername,
    required bool isMine,
  }) async {
    final c = Comment(
      id: _autoId++,
      tweetId: tweetId,
      authorName: authorName,
      authorUsername: authorUsername,
      content: content,
      createdAt: DateTime.now(),
      isMine: isMine,
    );

    _store.putIfAbsent(tweetId, () => []);
    _store[tweetId]!.add(c);
    return c;
  }

  @override
  Future<void> deleteComment({
    required int tweetId,
    required int commentId,
  }) async {
    final list = _store[tweetId];
    if (list == null) return;
    list.removeWhere((c) => c.id == commentId);
  }
}
