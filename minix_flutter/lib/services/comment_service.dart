import '../models/comment.dart';

abstract class CommentService {
  Future<List<Comment>> getComments(int tweetId);

  Future<Comment> addComment({
    required int tweetId,
    required String content,
    required String authorName,
    required String authorUsername,
    required bool isMine,
  });

  Future<void> deleteComment({
    required int tweetId,
    required int commentId,
  });
}
