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

  Future<List<Map<String, dynamic>>> getNowPlaying({
    int page = 1,
    String language = 'ko-KR',
  }) async {
    final res = await get(
      '/movie/now_playing',
      query: {'page': '$page', 'language': language},
    );

    if (!res.isOk) {
      throw Exception('TMDB error: ${res.statusCode} ${res.statusText}');
    }

    final body = res.body;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected TMDB response type: ${body.runtimeType}');
    }

    final results = body['results'];
    if (results is! List) return [];

    return results
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }
}
