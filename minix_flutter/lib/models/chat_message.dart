class ChatMessage {
  final String id;         // ✅ String 통일 (temp_도 가능)
  final String meetingId;
  final String content;
  final DateTime createdAt;

  final String authorName;
  final String authorUsername;

  final bool isMine;

  ChatMessage({
    required this.id,
    required this.meetingId,
    required this.content,
    required this.createdAt,
    required this.authorName,
    required this.authorUsername,
    required this.isMine,
  });

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    required String myUsername,
  }) {
    final idVal = json['id'] ?? json['_id'] ?? '';
    final meetingIdVal = json['meetingId'] ?? json['meeting_id'] ?? json['roomId'] ?? '';

    final user = (json['user'] is Map) ? Map<String, dynamic>.from(json['user']) : null;
    final authorUsername = (user?['username'] ?? json['authorUsername'] ?? json['username'] ?? '').toString().trim();
    final authorName = (user?['name'] ?? json['authorName'] ?? json['name'] ?? '익명').toString();

    final createdAtStr = (json['createdAt'] ?? json['created_at'] ?? '').toString();
    final createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();

    return ChatMessage(
      id: idVal.toString(),
      meetingId: meetingIdVal.toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: createdAt,
      authorName: authorName,
      authorUsername: authorUsername.isEmpty ? 'anonymous' : authorUsername,
      isMine: myUsername.isNotEmpty && authorUsername == myUsername,
    );
  }
}
