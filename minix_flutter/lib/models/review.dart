class Review {
  final int id;
  final String title;
  final String genre;
  final String content;
  final double rating;
  final String? posterUrl;

  final String name;
  final String username;
  final DateTime createdAt;

  final bool isLiked;
  final int likeCount;

  Review({
    required this.id,
    required this.title,
    required this.genre,
    required this.content,
    required this.rating,
    this.posterUrl,
    required this.name,
    required this.username,
    required this.createdAt,
    required this.isLiked,
    required this.likeCount,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      title: json['title'] ?? '',
      genre: json['genre'] ?? '',
      content: json['content'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      posterUrl: json['posterUrl'] ?? json['poster_url'],
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      isLiked: json['is_liked'] ?? false,
      likeCount: json['like_count'] ?? 0,
    );
  }

  Review copyWith({bool? isLiked, int? likeCount}) {
    return Review(
      id: id,
      title: title,
      genre: genre,
      content: content,
      rating: rating,
      posterUrl: posterUrl,
      name: name,
      username: username,
      createdAt: createdAt,
      isLiked: isLiked ?? this.isLiked,
      likeCount: likeCount ?? this.likeCount,
    );
  }
}
