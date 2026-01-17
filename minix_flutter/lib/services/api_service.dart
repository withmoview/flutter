// lib/services/api_service.dart
import 'dart:io';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

class ApiService extends GetConnect {
  final box = GetStorage();

  @override
  void onInit() {
    httpClient.baseUrl = 'https://flutter.banawy.store/api';
    httpClient.timeout = const Duration(seconds: 30);

    // Authorization 헤더 단일 관리
    httpClient.addRequestModifier<dynamic>((request) {
      final token = box.read('token');
      if (token != null && token.toString().isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      return request;
    });

    super.onInit();
  }

  // --------------------------
  // Helpers
  // --------------------------

  Map<String, dynamic> _asMap(dynamic body) {
    if (body is Map) return Map<String, dynamic>.from(body);
    return <String, dynamic>{};
  }

  List<dynamic> _asList(dynamic body) {
    if (body is List) return List<dynamic>.from(body);
    if (body is Map && body['data'] is List) return List<dynamic>.from(body['data']);
    return <dynamic>[];
  }

  Map<String, dynamic>? _dataMap(dynamic body) {
    final m = _asMap(body);
    final data = m['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    if (m.isNotEmpty) return m; // data 없이 오는 서버 대응
    return null;
  }

  // ==========================
  // Auth
  // ==========================

  Future<Response> register({
    required String email,
    required String password,
    required String name,
    required String username,
  }) {
    return post('/auth/register', {
      'email': email,
      'password': password,
      'name': name,
      'username': username,
    });
  }

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    final res = await post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (res.statusCode == 200) {
      final body = _asMap(res.body);
      final token = body['token']?.toString();
      final userMap = (body['user'] is Map) ? Map<String, dynamic>.from(body['user']) : null;

      if (token == null || token.isEmpty) throw Exception('token 없음: $body');
      if (userMap == null) throw Exception('user 없음: $body');

      await box.write('token', token);
      return userMap;
    }

    final body = _asMap(res.body);
    final msg = body['detail'] ?? body['message'];
    throw Exception(msg?.toString() ?? '로그인 실패(${res.statusCode})');
  }

  void clearToken() {
    box.remove('token');
  }

  // ==========================
  // Tweets
  // ==========================

  Future<List<dynamic>> getTimeline() async {
    final res = await get('/tweets');
    if (res.statusCode == 200) {
      // 서버가 {data:[...]} 형태라고 가정 (기존 방식 유지)
      return _asList(res.body is Map ? res.body : {'data': res.body});
    }
    return [];
  }

  Future<Response> createTweet(String content) {
    return post('/tweets', {'content': content});
  }

  Future<bool> deleteTweet(int id) async {
    final res = await delete('/tweets/$id');
    return res.statusCode == 200 || res.statusCode == 204;
  }

  Future<Map<String, dynamic>?> toggleLike(int tweetId) async {
    final res = await post('/tweets/$tweetId/like', {});
    if (res.statusCode == 200) {
      final data = _dataMap(res.body);
      if (data == null) return null;

      final liked = data['liked'] ?? data['is_liked'];
      final likeCount = data['like_count'] ?? data['likeCount'];

      return {
        'liked': liked == true || liked == 1,
        'like_count': (likeCount is num) ? likeCount.toInt() : int.tryParse('$likeCount') ?? 0,
      };
    }
    return null;
  }

  // ==========================
  // Users / Profile
  // ==========================

  Future<Map<String, dynamic>?> getMyProfile() async {
    final res = await get('/users/me');
    if (res.statusCode == 200) return _dataMap(res.body);
    return null;
  }

  Future<List<dynamic>> getMyTweets() async {
    final res = await get('/users/me/tweets');
    if (res.statusCode == 200) {
      return _asList(res.body is Map ? res.body : {'data': res.body});
    }
    return [];
  }

  Future<int?> uploadImage(XFile image) async {
    final form = FormData({
      'file': MultipartFile(File(image.path), filename: image.name),
    });

    final res = await post('/files', form, contentType: 'multipart/form-data');

    if (res.statusCode == 201 || res.statusCode == 200) {
      final data = _dataMap(res.body);
      final id = data?['id'];
      if (id is int) return id;
      return int.tryParse('$id');
    }
    return null;
  }

  String getImageUrl(int fileId) => '${httpClient.baseUrl}/files/$fileId';

  Future<Map<String, dynamic>?> updateProfile({
    String? name,
    int? profileImageId,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (profileImageId != null) data['profile_image_id'] = profileImageId;

    final res = await put('/users/me', data);
    if (res.statusCode == 200) return _dataMap(res.body);
    return null;
  }

  // ==========================
  // Meetings
  // ==========================

  Future<List<dynamic>> getMeetings() async {
    final res = await get('/meetings');
    if (res.statusCode == 200) {
      // 서버: { data: [MeetingOut...] }
      return _asList(res.body);
    }
    return [];
  }

  Future<Map<String, dynamic>?> getMeeting(String meetingId) async {
    final res = await get('/meetings/$meetingId');
    if (res.statusCode == 200) {
      return _dataMap(res.body); // {data:{...}} → {...}
    }
    return null;
  }

  Future<Map<String, dynamic>?> createMeeting({
    required String title,
    required String movieTitle,
    int? movieId,
    String? moviePosterPath,
    required String theater,
    required DateTime meetingTime,
    required String password,
    int maxMembers = 4,
  }) async {
    final res = await post('/meetings', {
      'title': title,
      'movieTitle': movieTitle,
      'movieId': movieId,
      'moviePosterPath': moviePosterPath,
      'theater': theater,
      'meetingTime': meetingTime.toIso8601String(),
      'password': password,
      'maxMembers': maxMembers,
    });

    if (res.statusCode == 201 || res.statusCode == 200) {
      return _dataMap(res.body); // {data:{...}} → {...}
    }
    return null;
  }

  Future<Map<String, dynamic>?> joinMeeting({
    required String meetingId,
    required String password,
  }) async {
    final res = await post('/meetings/$meetingId/join', {'password': password});
    if (res.statusCode == 200) {
      return _dataMap(res.body); // {data:{...}} → {...}
    }
    return null;
  }

  /// ✅ 서버가 204 No Content
  Future<bool> leaveMeeting({required String meetingId}) async {
    final res = await post('/meetings/$meetingId/leave', {});
    return res.statusCode == 204 || res.statusCode == 200;
  }

  Future<bool> deleteMeeting(String meetingId) async {
    final res = await delete('/meetings/$meetingId');
    return res.statusCode == 204 || res.statusCode == 200;
  }

  // ==========================
  // Chat (Meeting Messages)
  // ==========================

  Future<List<dynamic>> getMeetingMessages(String meetingId) async {
    final res = await get('/meetings/$meetingId/messages');
    if (res.statusCode == 200) {
      // 서버: list[ChatMessageOut]
      return _asList(res.body);
    }
    return [];
  }

  Future<Map<String, dynamic>?> sendMeetingMessage({
    required String meetingId,
    required String content,
  }) async {
    final res = await post('/meetings/$meetingId/messages', {'content': content});
    if (res.statusCode == 201 || res.statusCode == 200) {
      // 서버: ChatMessageOut object
      if (res.body is Map) return Map<String, dynamic>.from(res.body);
      return null;
    }
    return null;
  }
}
