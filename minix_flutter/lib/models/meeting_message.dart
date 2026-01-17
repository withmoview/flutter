class MeetingMessage {
  final String id;
  final String meetingId;

  final String content;
  final DateTime createdAt;

  final String authorName;
  final String authorUsername;

  final bool isMine;

  MeetingMessage({
    required this.id,
    required this.meetingId,
    required this.content,
    required this.createdAt,
    required this.authorName,
    required this.authorUsername,
    required this.isMine,
  });

  factory MeetingMessage.fromJson(
    Map<String, dynamic> json, {
    required String meetingId,
    required String myUsername,
  }) {
    final user = (json['user'] is Map) ? Map<String, dynamic>.from(json['user']) : null;

    final authorUsername =
        (user?['username'] ?? json['authorUsername'] ?? json['username'] ?? '').toString();
    final authorName = (user?['name'] ?? json['authorName'] ?? json['name'] ?? '익명').toString();

    final createdAtStr = (json['createdAt'] ?? json['created_at'] ?? json['time'] ?? '').toString();
    final createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();

    final id = (json['id'] ?? json['_id'] ?? json['messageId'] ?? '').toString();

    final mine = myUsername.isNotEmpty && authorUsername == myUsername;

    return MeetingMessage(
      id: id.isEmpty ? '${createdAt.microsecondsSinceEpoch}' : id,
      meetingId: meetingId,
      content: (json['content'] ?? json['text'] ?? '').toString(),
      createdAt: createdAt,
      authorName: authorName,
      authorUsername: authorUsername.isEmpty ? 'anonymous' : authorUsername,
      isMine: mine,
    );
  }
}
