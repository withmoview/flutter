import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/tmdb_service.dart';

class MoviePickResult {
  final int id;
  final String title;
  final String? posterPath;
  final String? releaseDate;

  MoviePickResult({
    required this.id,
    required this.title,
    this.posterPath,
    this.releaseDate,
  });
}

class MovieSearchScreen extends StatefulWidget {
  const MovieSearchScreen({super.key});

  @override
  State<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final _text = TextEditingController();
  Timer? _debounce;

  bool _loading = false;
  List<Map<String, dynamic>> _items = [];

  late final TmdbService _tmdb;

  @override
  void initState() {
    super.initState();
    _tmdb = Get.find<TmdbService>();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _onChange(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(v.trim());
    });
  }

  Future<void> _search(String q) async {
    if (q.isEmpty) {
      setState(() => _items = []);
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await _tmdb.searchMovies(query: q, page: 1, language: 'ko-KR');
      setState(() => _items = res);
    } catch (e) {
      Get.snackbar("오류", "검색 실패: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  String? _posterUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    return 'https://image.tmdb.org/t/p/w500$path';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('영화 검색', style: GoogleFonts.notoSansKr(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: TextField(
              controller: _text,
              onChanged: _onChange,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '영화 제목을 검색하세요',
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          if (_loading)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(),
            ),

          Expanded(
            child: ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final m = _items[i];
                final id = (m['id'] ?? 0) as int;
                final title = (m['title'] ?? m['name'] ?? '제목 없음').toString();
                final posterPath = m['poster_path']?.toString();
                final releaseDate = m['release_date']?.toString();

                final url = _posterUrl(posterPath);

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 46,
                      height: 70,
                      child: url == null
                          ? Container(color: Colors.grey.shade300, child: const Icon(Icons.movie))
                          : Image.network(url, fit: BoxFit.cover),
                    ),
                  ),
                  title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSansKr(fontWeight: FontWeight.w700)),
                  subtitle: Text(releaseDate ?? '',
                      style: GoogleFonts.notoSansKr(color: Colors.black54)),
                  onTap: () {
                    Get.back(
                      result: MoviePickResult(
                        id: id,
                        title: title,
                        posterPath: posterPath,
                        releaseDate: releaseDate,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
