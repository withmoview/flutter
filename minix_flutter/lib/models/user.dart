import 'package:flutter/cupertino.dart';

class User {
  final int id;
  final String email;
  final String name;
  final String username;
  final String? profileImage; 
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.username,
    this.profileImage, 
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as num).toInt(),
      email: (json['email'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      username: (json['username'] ?? '') as String,
      profileImage: json['profileImage'] as String?, 
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
    );
  }
}


// class User{
//   final int id;
//   final String email;
//   final String name;
//   final String username;
//   final String? profileImage;
//   final DateTime createdAt;

//   User({
//     required this.id,
//     required this.email,
//     required this.name,
//     required this.username,
//     this.profileImage,
//     required this.createdAt,
//   });

//   factory User.fromJson(Map<String, dynamic> json){
//     return User(
//       id: json['id'],
//       email: json['email'],
//       name: json['name'],
//       username: json['username'],
//       profileImage: json['profile_image'],
//       createdAt: DateTime.parse(json['created_at']),
//     );
//   }
// }