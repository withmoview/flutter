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

  // ✅ 포스터 이미지 URL 생성
  String imageUrl(String? posterPath, {int width = 500}) {
    if (posterPath == null || posterPath.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w$width$posterPath';
  }

  // ✅ 현재 상영작
  Future<List<Map<String, dynamic>>> getNowPlaying({
    int page = 1,
    String language = 'ko-KR',
  }) async {
    return _fetchList(
      '/movie/now_playing',
      {
        'page': '$page',
        'language': language,
        'region': 'KR',
      },
    );
  }

  // ✅ 인기 영화
  Future<List<Map<String, dynamic>>> getPopularMovies({
    int page = 1,
    String language = 'ko-KR',
  }) async {
    return _fetchList(
      '/movie/popular',
      {
        'page': '$page',
        'language': language,
        'region': 'KR',
      },
    );
  }

  // ✅ 영화 검색
  Future<List<Map<String, dynamic>>> searchMovies({
    required String query,
    int page = 1,
    String language = 'ko-KR',
  }) async {
    return _fetchList(
      '/search/movie',
      {
        'query': query,
        'page': '$page',
        'language': language,
        'include_adult': 'false',
        'region': 'KR',
      },
    );
  }

  // ✅ 장르 맵 캐싱
  Map<int, String>? _genreMapCache;

  Future<Map<int, String>> getGenreMap({String language = 'ko-KR'}) async {
    if (_genreMapCache != null) return _genreMapCache!;

    final res = await get('/genre/movie/list', query: {'language': language});

    if (!res.isOk) {
      print('TMDB Genre Error: ${res.statusCode} / ${res.bodyString}');
      throw Exception('TMDB genre error: ${res.statusCode} ${res.statusText}');
    }

    final body = res.body;
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected TMDB response type: ${body.runtimeType}');
    }

    final genres = body['genres'];
    if (genres is! List) return {};

    final map = <int, String>{};
    for (final g in genres) {
      if (g is Map) {
        final id = g['id'];
        final name = g['name'];
        if (id is int && name is String) map[id] = name;
      }
    }

    _genreMapCache = map;
    return map;
  }

  // -------------------------
  // 내부 공통 fetch
  // -------------------------
  Future<List<Map<String, dynamic>>> _fetchList(
    String endpoint,
    Map<String, dynamic> query,
  ) async {
    final res = await get(endpoint, query: query);

    if (!res.isOk) {
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
