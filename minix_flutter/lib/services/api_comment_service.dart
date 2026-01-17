import 'package:get/get.dart';
import '../models/comment.dart';
import '../services/api_service.dart';
import 'comment_service.dart';

class ApiCommentService implements CommentService {
  final ApiService _api;

  ApiCommentService({required ApiService api}) : _api = api;

  @override
  Future<List<Comment>> getComments(int tweetId) async {
    final res = await _api.get('/tweets/$tweetId/comments');

    if (res.statusCode != 200) {
      final msg = _pickMsg(res.body) ?? '댓글 목록 조회 실패(${res.statusCode})';
      throw Exception(msg);
    }

    final body = res.body;
    final rawList = _extractList(body);

    return rawList
        .whereType<Map>()
        .map((m) => Comment.fromJson(Map<String, dynamic>.from(m), tweetId: tweetId))
        .toList();
  }

  @override
  Future<Comment> addComment({
    required int tweetId,
    required String content,
  }) async {
    final res = await _api.post('/tweets/$tweetId/comments', {
      'content': content,
    });

    if (res.statusCode != 201 && res.statusCode != 200) {
      final msg = _pickMsg(res.body) ?? '댓글 작성 실패(${res.statusCode})';
      throw Exception(msg);
    }

    final body = res.body;
    final raw = _extractMap(body) ?? <String, dynamic>{};

    // 서버가 생성된 댓글을 data로 돌려주거나 body로 바로 줄 수 있음
    return Comment.fromJson(raw, tweetId: tweetId);
  }

  @override
  Future<void> deleteComment({
    required int tweetId,
    required int commentId,
  }) async {
    final res = await _api.delete('/tweets/$tweetId/comments/$commentId');

    if (res.statusCode != 200 && res.statusCode != 204) {
      final msg = _pickMsg(res.body) ?? '댓글 삭제 실패(${res.statusCode})';
      throw Exception(msg);
    }
  }

  // ----------------------
  // helpers
  // ----------------------

  List<dynamic> _extractList(dynamic body) {
    if (body is Map && body['data'] is List) return body['data'] as List;
    if (body is List) return body;
    return const [];
  }

  Map<String, dynamic>? _extractMap(dynamic body) {
    if (body is Map && body['data'] is Map) return Map<String, dynamic>.from(body['data']);
    if (body is Map) return Map<String, dynamic>.from(body);
    return null;
  }

  String? _pickMsg(dynamic body) {
    if (body is Map) {
      return (body['detail'] ?? body['message'])?.toString();
    }
    return null;
  }
}
