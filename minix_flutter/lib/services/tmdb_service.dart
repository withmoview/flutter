import 'package:get/get.dart';

class TmdbService extends GetConnect {
  final String accessToken;

  TmdbService(this.accessToken) {
    httpClient.baseUrl = 'https://api.themoviedb.org/3';
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.headers['Content-Type'] = 'application/json;charset=utf-8';
      return request;
    });
  }

  // 1. 최신 영화 (한국어)
  Future<List<Map<String, dynamic>>> getNowPlaying({
    int page = 1,
    String language = 'ko-KR',
  }) async {
    // 아래 공통 함수(_fetchList)를 사용해서 코드를 줄입니다.
    return _fetchList(
      '/movie/now_playing',
      {'page': '$page', 'language': language, 'region': 'KR'}, 
    );
  }

  // 2. 인기 영화 (한국 인기순 + 한국어)
  Future<List<Map<String, dynamic>>> getPopularMovies({
    int page = 1,
  }) async {
    return _fetchList(
      '/movie/popular',
      {'page': '$page', 'language': 'ko-KR', 'region': 'KR'},
    );
  }

  // [내부 전용 함수] API 요청 및 데이터 가공을 담당
  Future<List<Map<String, dynamic>>> _fetchList(
    String endpoint, 
    Map<String, dynamic> query,
  ) async {
    // GetConnect의 get 메서드 사용
    final res = await get(endpoint, query: query);

    if (!res.isOk) {
      // 에러 로그 출력 (디버깅용)
      print('TMDB Error: ${res.statusCode} / ${res.bodyString}');
      throw Exception('TMDB error: ${res.statusCode} ${res.statusText}');
    }

    final body = res.body;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected TMDB response type: ${body.runtimeType}');
    }

    final results = body['results'];
    if (results is! List) return [];

    return results.whereType<Map<String, dynamic>>().toList(growable: false);
  }
}