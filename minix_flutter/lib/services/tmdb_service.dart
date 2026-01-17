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

  String imageUrl(String? posterPath, {int width = 500}) {
    if (posterPath == null || posterPath.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w$width$posterPath';
  }

  Future<List<Map<String, dynamic>>> searchMovies({
    required String query,
    int page = 1,
    String language = 'ko-KR',
  }) async {
    final res = await get(
      '/search/movie',
      query: {'query': query, 'page': '$page', 'language': language, 'include_adult': 'false'},
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

    return results.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  Map<int, String>? _genreMapCache;

  Future<Map<int, String>> getGenreMap({String language = 'ko-KR'}) async {
    if (_genreMapCache != null) return _genreMapCache!;

    final res = await get('/genre/movie/list', query: {'language': language});
    if (!res.isOk) {
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

    return results.whereType<Map<String, dynamic>>().toList(growable: false);
  }
}
