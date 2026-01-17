import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

//api 통신을 하기 위한 기본 클래스
class ApiService extends GetConnect{
  String? _token; //통신에 사용할 인증 Token
  final box = GetStorage();

  Future<Response> register({
    required String email,
    required String password,
    required String name,
    required String username,
  }) async{
    return await post('/auth/register',{
      'email' : email,
      'password' : password,
      'name' : name,
      'username' : username,
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

    print('LOGIN status=${res.statusCode}');
    print('LOGIN body=${res.body}'); 
    print('LOGIN bodyType=${res.body.runtimeType}');

    if (res.statusCode == 200) {
      final body = (res.body is Map)
          ? Map<String, dynamic>.from(res.body)
          : <String, dynamic>{};

      final token = body['token']?.toString();
      final userMap = (body['user'] is Map)
          ? Map<String, dynamic>.from(body['user'])
          : null;

      print('PARSED token=$token');
      print('PARSED user=$userMap');

      if (token == null || token.isEmpty) {
        throw Exception('로그인 응답에 token이 없습니다: $body');
      }
      if (userMap == null) {
        throw Exception('로그인 응답에 user가 없습니다: $body');
      }

      setToken(token);
      await box.write('token',token);
      return userMap;
    }

    // 실패 시 서버 메시지 보여주기
    final msg = (res.body is Map) ? (res.body['detail'] ?? res.body['message']) : null;
    throw Exception(msg?.toString() ?? '로그인 실패(${res.statusCode})');
}


  @override
  void onInit(){

    //서버 주소를 설정
    httpClient.baseUrl = 'http://10.0.2.2:3000/api';

    httpClient.addRequestModifier<dynamic>((request){
      final token = box.read('token');
      if(token != null){
        request.headers['Authorization'] = 'Bearer $token';
      }
      return request;
    });

    httpClient.timeout = const Duration(seconds: 30);

    httpClient.addRequestModifier<dynamic>((request) async {
      if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
      }
      return request;
    });

    super.onInit();
  }

  void setToken(String? token){
    _token = token;
  }
  
  void clearToken(){
    _token = null;
  }

  Future<List<dynamic>> getTimeline() async{
    final res = await get('/tweets');
    if(res.statusCode == 200){
      return res.body['data'] ?? [];
    }
    return  [];
  }

  Future<Response> createTweet(String content) async{
    return await post('/tweets', {'content': content});
  }

  Future<bool> deleteTweet(int id) async{
    final res = await delete('/tweets/$id');
    return res.statusCode == 200;
  }
  Future<Map<String, dynamic>?> toggleLike(int tweetId) async{
    final res = await post('/tweets/$tweetId/like', {});
    if(res.statusCode == 200){
      return res.body;
    }
    return null;
  }

  // 내 프로필 조회
  Future<Map<String, dynamic>?> getMyProfile() async {
  final res = await get('/users/me');
  if (res.statusCode == 200) {
    return res.body['data'];  // 유저 정보 반환
  }
  return null;
  }
  // 내가 쓴 트윗 목록
  Future<List<dynamic>> getMyTweets() async {
  final res = await get('/users/me/tweets');
  if (res.statusCode == 200) {
    return res.body['data'] ?? [];
  }
  return [];
  }

  Future<int?> uploadImage(XFile image) async{
    final form = FormData({
      'file' : MultipartFile(
        File(image.path),
        filename: image.name,
      ),
    });

    final res = await post('/files', form);

    if(res.statusCode == 201){
      return res.body['data']['id'];
    }
    return null;
  }

  String getImageUrl(int fileId){
    return '${httpClient.baseUrl}/files/$fileId';
  }

  Future<Map<String, dynamic>?> updateProfile({
    String? name,
    int? profileImageId,
  }) async{
    final data = <String, dynamic>{};
    if(name != null) data['name'] = name;
    if(profileImageId != null) data['profile_image_id'] = profileImageId;

    final res = await put('/users/me', data);
    if(res.statusCode == 200){
      return res.body['data'];
    }
    return null;
  }
}