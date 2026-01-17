class Comment {
  final int id;
  final int tweetId;

  final String authorName;
  final String authorUsername;

  final String content;
  final DateTime createdAt;

  /// 내 댓글인지(UI에서 삭제 버튼 노출)
  final bool isMine;

  Comment({
    required this.id,
    required this.tweetId,
    required this.authorName,
    required this.authorUsername,
    required this.content,
    required this.createdAt,
    required this.isMine,
  });

  factory Comment.fromJson(Map<String, dynamic> json, {required int tweetId}) {
    // user가 중첩일 수도 있음
    final user = (json['user'] is Map) ? Map<String, dynamic>.from(json['user']) : null;

    final idVal = json['id'] ?? json['comment_id'] ?? json['commentId'];
    final id = (idVal is num) ? idVal.toInt() : int.tryParse(idVal?.toString() ?? '') ?? -1;

    final authorName = (user?['name'] ??
            json['author_name'] ??
            json['authorName'] ??
            json['name'] ??
            '익명')
        .toString();

    final authorUsername = (user?['username'] ??
            json['author_username'] ??
            json['authorUsername'] ??
            json['username'] ??
            'anonymous')
        .toString();

    final content = (json['content'] ?? json['text'] ?? '').toString();

    final createdAtStr = (json['created_at'] ?? json['createdAt'] ?? '').toString();
    final createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();

    final isMineRaw = json['is_mine'] ?? json['isMine'];
    final isMine = (isMineRaw is bool) ? isMineRaw : false;

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

  Comment copyWith({
    bool? isMine,
  }) {
    return Comment(
      id: id,
      tweetId: tweetId,
      authorName: authorName,
      authorUsername: authorUsername,
      content: content,
      createdAt: createdAt,
      isMine: isMine ?? this.isMine,
    );
  }
}
