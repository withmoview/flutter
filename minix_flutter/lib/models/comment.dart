class Comment {
  final int id;
  final int tweetId;
  final String authorName;
  final String authorUsername;
  final String content;
  final DateTime createdAt;
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
}
