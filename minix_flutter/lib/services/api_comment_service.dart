import 'package:get/get.dart';
import '../models/comment.dart';
import '../services/api_service.dart';
import 'comment_service.dart';

/// ✅ 서버 댓글 API 구현체(뼈대)
/// - CommentService 규격을 그대로 구현
/// - ApiService(GetConnect)를 통해 HTTP 호출
///
/// ⚠️ 백엔드 API 스펙에 맞게 아래 TODO 부분만 수정하면 됨.
class ApiCommentService implements CommentService {
  final ApiService _api;

  ApiCommentService({required ApiService api}) : _api = api;

  // =========================
  // 1) 댓글 목록 가져오기
  // =========================
  @override
  Future<List<Comment>> getComments(int tweetId) async {
    // TODO(백엔드): 엔드포인트 확정 필요
    // 예시 A: /tweets/:id/comments
    // 예시 B: /reviews/:id/comments
    final res = await _api.get('/tweets/$tweetId/comments');

    if (res.statusCode != 200) {
      throw Exception('댓글 목록 조회 실패 (${res.statusCode})');
    }

    // TODO(백엔드): 응답 JSON 구조 확정 필요
    // 예시: { "data": [ {...}, {...} ] }
    // 또는: [ {...}, {...} ]
    final body = res.body;

    List<dynamic> rawList;
    if (body is Map && body['data'] is List) {
      rawList = body['data'] as List;
    } else if (body is List) {
      rawList = body;
    } else {
      rawList = [];
    }

    // TODO(백엔드): 댓글 JSON 필드명 확정 필요
    // 아래 파서는 최대한 “유연하게” 적어둠. 서버 필드명에 맞게 정리하면 됨.
    return rawList
        .whereType<Map>()
        .map((m) => _commentFromJson(tweetId, Map<String, dynamic>.from(m)))
        .toList();
  }

  // =========================
  // 2) 댓글 추가
  // =========================
  @override
  Future<Comment> addComment({
    required int tweetId,
    required String content,
    required String authorName,
    required String authorUsername,
    required bool isMine,
  }) async {
    // TODO(백엔드): 엔드포인트 확정 필요
    final res = await _api.post('/tweets/$tweetId/comments', {
      'content': content,
      // 백엔드가 토큰에서 user를 알면 content만 보내도 됨
      // 'authorName': authorName,
      // 'authorUsername': authorUsername,
    });

    // 성공 코드는 구현 따라 201/200일 수 있음
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('댓글 작성 실패 (${res.statusCode})');
    }

    // TODO(백엔드): 생성된 댓글을 응답으로 주면 그걸 파싱해서 반환
    // 예시: { "data": { ...comment... } }
    // 아니면: { ...comment... }
    final body = res.body;
    Map<String, dynamic> commentJson;

    if (body is Map && body['data'] is Map) {
      commentJson = Map<String, dynamic>.from(body['data']);
    } else if (body is Map) {
      commentJson = Map<String, dynamic>.from(body);
    } else {
      // 서버가 댓글을 돌려주지 않는 경우(rare):
      // 프론트에서 임시 Comment 만들어서 반환할 수도 있지만,
      // 보통은 서버가 생성된 댓글을 반환하도록 요청하는 게 좋음.
      commentJson = {
        'id': -1,
        'content': content,
        'createdAt': DateTime.now().toIso8601String(),
        'authorName': authorName,
        'authorUsername': authorUsername,
      };
    }

    return _commentFromJson(tweetId, commentJson);
  }

  // =========================
  // 3) 댓글 삭제
  // =========================
  @override
  Future<void> deleteComment({
    required int tweetId,
    required int commentId,
  }) async {
    // TODO(백엔드): 엔드포인트 확정 필요
    // 예시 A: /tweets/:tweetId/comments/:commentId
    // 예시 B: /comments/:commentId
    final res = await _api.delete('/tweets/$tweetId/comments/$commentId');

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('댓글 삭제 실패 (${res.statusCode})');
    }
  }

  // =========================
  // JSON -> Comment 변환(유연 파서)
  // =========================
  Comment _commentFromJson(int tweetId, Map<String, dynamic> json) {
    // 서버마다 필드명이 다를 수 있어서 여러 후보를 넣어둠.
    final id = _asInt(json['id'] ?? json['commentId']) ?? -1;

    // user가 중첩일 수도 있고, 평면일 수도 있음
    final user = (json['user'] is Map) ? Map<String, dynamic>.from(json['user']) : null;

    final authorName =
        (user?['name'] ?? json['authorName'] ?? json['name'] ?? '익명').toString();
    final authorUsername =
        (user?['username'] ?? json['authorUsername'] ?? json['username'] ?? 'anonymous')
            .toString();

    final content = (json['content'] ?? json['text'] ?? '').toString();

    final createdAtStr =
        (json['createdAt'] ?? json['created_at'] ?? json['time'] ?? '').toString();
    final createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();

    // isMine은 서버가 주면 그걸 쓰고, 아니면 일단 false (UI에서 삭제 버튼 판단에 사용)
    final isMine = (json['isMine'] is bool) ? (json['isMine'] as bool) : false;

    return Comment(
      id: id,
      tweetId: tweetId,
      authorName: authorName,
      authorUsername: authorUsername,
      content: content,
      createdAt: createdAt,
      isMine: isMine,
    );
  }

  int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }
}
