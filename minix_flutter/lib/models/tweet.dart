class Tweet {
  final int id;
  final int userId;
  final String content;
  final String? image; // image_id 등을 문자열로 보관(필요시 int로 바꿔도 됨)
  final DateTime createdAt;

  final String name;
  final String username;

  final String? profileImage;
  final int? profile_image_id;

  final int likeCount;
  final bool isLiked;

  Tweet({
    required this.id,
    required this.userId,
    required this.content,
    this.image,
    required this.createdAt,
    required this.name,
    required this.username,
    this.profileImage,
    this.profile_image_id,
    required this.likeCount,
    required this.isLiked,
  });

  factory Tweet.fromJson(Map<String, dynamic> json) {
    return Tweet(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      content: (json['content'] ?? '') as String,
      image: json['image_id']?.toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ?? DateTime.now(),
      name: (json['name'] ?? '알 수 없음').toString(),
      username: (json['username'] ?? 'unknown').toString(),
      profileImage: json['profile_image']?.toString(),
      profile_image_id: (json['profile_image_id'] as num?)?.toInt(),
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] == true || json['is_liked'] == 1,
    );
  }

  Tweet copyWith({
    int? likeCount,
    bool? isLiked,
    String? content,
    String? image,
    int? profileImageId,
  }) {
    return Tweet(
      id: id,
      userId: userId,
      content: content ?? this.content,
      image: image ?? this.image,
      createdAt: createdAt,
      name: name,
      username: username,
      profileImage: profileImage,
      profile_image_id: profileImageId ?? profile_image_id,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
