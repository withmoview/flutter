import 'package:get/get.dart';

class Tweet {
  final int id;
  final int userId;
  final String content;
  final String? image; // 트윗 이미지 ID (혹은 경로)
  final DateTime createdAt;
  final String name;
  final String username;
  final String? profileImage; // 프로필 이미지 ID
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
    required this.likeCount,
    required this.isLiked,
  });

  factory Tweet.fromJson(Map<String, dynamic> json) {
    // ★ 수정됨: 'author' 객체를 만드는 과정을 삭제하고 바로 데이터를 꺼냅니다.
    
    return Tweet(
      id: json['id'] as int,
      // DB의 컬럼명은 user_id 입니다.
      userId: (json['user_id'] ?? 0) as int, 
      
      content: (json['content'] ?? '') as String,
      
      // DB 컬럼이 image_id라면 이렇게 받아야 합니다. (문자열로 변환)
      image: json['image_id']?.toString(), 
      
      createdAt: DateTime.parse((json['created_at'] ?? DateTime.now().toString()).toString()),
      
      // ★ 여기가 핵심입니다! author['name']이 아니라 json['name']으로 바로 접근
      name: (json['name'] ?? '알 수 없음') as String,
      username: (json['username'] ?? 'unknown') as String,
      
      // DB 컬럼이 profile_image_id 입니다.
      profileImage: json['profile_image_id']?.toString(),
      
      likeCount: (json['like_count'] ?? 0) as int,
      isLiked: json['is_liked'] == true || json['is_liked'] == 1,
    );
  }

  // copyWith: 일부 값만 바꾼 새 객체 생성 (좋아요 토글용)
  Tweet copyWith({int? likeCount, bool? isLiked}) {
    return Tweet(
      id: id, 
      userId: userId, 
      content: content, 
      image: image,
      createdAt: createdAt, 
      name: name, 
      username: username,
      profileImage: profileImage,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}



// import 'package:get/get.dart';

// class Tweet{
//   final int id;
//   final int userId;
//   final String content;
//   final String? image;
//   final DateTime createdAt;
//   final String name;
//   final String username;
//   final String? profileImage;
//   final int likeCount;
//   final bool isLiked;

//   Tweet({
//     required this.id,
//     required this.userId,
//     required this.content,
//     this.image,
//     required this.createdAt,
//     required this.name,
//     required this.username,
//     this.profileImage,
//     required this.likeCount,
//     required this.isLiked,
//   });

//    factory Tweet.fromJson(Map<String, dynamic> json) {
//   final author = (json['author'] is Map<String, dynamic>)
//       ? json['author'] as Map<String, dynamic>
//       : <String, dynamic>{};

//   return Tweet(
//     id: json['id'] as int,
//     userId: (author['id'] ?? 0) as int, // 
//     content: (json['content'] ?? '') as String,
//     image: json['image'] as String?,    // 서버가 없으면 null OK
//     createdAt: DateTime.parse((json['created_at'] ?? '').toString()),
//     name: (author['name'] ?? '') as String,
//     username: (author['username'] ?? '') as String,
//     profileImage: author['profile_image'] as String?,
//     likeCount: (json['like_count'] ?? 0) as int,
//     isLiked: json['is_liked'] == true || json['is_liked'] == 1,
//   );
// }

//  // copyWith: 일부 값만 바꾼 새 객체 생성 (좋아요 토글용)
//  Tweet copyWith({int? likeCount, bool? isLiked}) {
//    return Tweet(
//      id: id, userId: userId, content: content, image: image,
//      createdAt: createdAt, name: name, username: username,
//      profileImage: profileImage,
//      likeCount: likeCount ?? this.likeCount,
//      isLiked: isLiked ?? this.isLiked,
//    );
//  }
// }

