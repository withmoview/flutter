import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:minix_flutter/controllers/TweetController.dart';
import 'package:minix_flutter/services/tmdb_service.dart';

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key});

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final _tweetController = Get.find<TweetController>();
  final _tmdb = Get.find<TmdbService>();

  final _titleCtrl = TextEditingController();
  final _genreCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  double _rating = 0;
  bool _isLoading = false;

  // ✅ 선택된 영화 정보
  int? _tmdbId;
  String _posterUrl = '';

  Future<void> _openMoviePicker() async {
    final selected = await showModalBottomSheet<_MoviePickResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MoviePickerSheet(tmdb: _tmdb),
    );

    if (selected == null) return;

    setState(() {
      _tmdbId = selected.tmdbId;
      _posterUrl = selected.posterUrl;
      _titleCtrl.text = selected.title;
      if (selected.genre.isNotEmpty) _genreCtrl.text = selected.genre;
    });
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) {
      Get.snackbar('오류', '영화 제목을 입력해주세요');
      return;
    }
    if (_contentCtrl.text.trim().isEmpty) {
      Get.snackbar('오류', '감상평을 입력해주세요');
      return;
    }
    if (_rating <= 0) {
      Get.snackbar('오류', '별점을 입력해주세요');
      return;
    }

    setState(() => _isLoading = true);

    final success = await _tweetController.createReview(
      title: _titleCtrl.text,
      genre: _genreCtrl.text,
      rating: _rating,
      content: _contentCtrl.text,
      posterUrl: _posterUrl, // ✅ 핵심: URL 저장
      tmdbId: _tmdbId,
    );

    if (mounted) setState(() => _isLoading = false);

    if (success) Get.back();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _genreCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('리뷰 작성'),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('게시'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 포스터 + 제목/장르
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ 포스터: 선택되면 자동 표시
                  GestureDetector(
                    onTap: _openMoviePicker,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 92,
                        height: 130,
                        color: const Color(0xFFF0F2F6),
                        child: (_posterUrl.isEmpty)
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search, color: Colors.grey),
                                  SizedBox(height: 6),
                                  Text('영화 선택', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              )
                            : Image.network(
                                _posterUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.local_movies_outlined,
                                  color: Colors.grey,
                                  size: 28,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        // 제목: 직접 입력도 가능하지만 추천은 "영화 선택"
                        TextField(
                          controller: _titleCtrl,
                          readOnly: true,
                          onTap: _openMoviePicker,
                          decoration: const InputDecoration(
                            labelText: '영화 제목 (눌러서 선택)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _genreCtrl,
                          decoration: const InputDecoration(
                            labelText: '장르 (자동/수정 가능)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 별점
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('별점', style: TextStyle(fontWeight: FontWeight.w800)),
                  const Spacer(),
                  RatingBar.builder(
                    initialRating: _rating,
                    minRating: 0,
                    allowHalfRating: true,
                    itemSize: 28,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 2),
                    itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (v) => setState(() => _rating = v),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _rating == 0 ? '-' : _rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 감상평
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _contentCtrl,
                maxLines: 10,
                maxLength: 800,
                decoration: const InputDecoration(
                  labelText: '감상평',
                  hintText: '스포일러는 표시해 주세요 🙂',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoviePickResult {
  final int tmdbId;
  final String title;
  final String posterUrl;
  final String genre;

  _MoviePickResult({
    required this.tmdbId,
    required this.title,
    required this.posterUrl,
    required this.genre,
  });
}

class _MoviePickerSheet extends StatefulWidget {
  final TmdbService tmdb;
  const _MoviePickerSheet({required this.tmdb});

  @override
  State<_MoviePickerSheet> createState() => _MoviePickerSheetState();
}

class _MoviePickerSheetState extends State<_MoviePickerSheet> {
  final _qCtrl = TextEditingController();
  bool _loading = false;
  List<Map<String, dynamic>> _items = [];
  Map<int, String> _genreMap = {};

  @override
  void initState() {
    super.initState();
    _initGenres();
  }

  Future<void> _initGenres() async {
    try {
      _genreMap = await widget.tmdb.getGenreMap();
      setState(() {});
    } catch (_) {}
  }

  String _genresText(List ids) {
    final names = <String>[];
    for (final id in ids) {
      if (id is int && _genreMap.containsKey(id)) names.add(_genreMap[id]!);
    }
    if (names.isEmpty) return '';
    return names.take(2).join(', ');
  }

  Future<void> _search() async {
    final q = _qCtrl.text.trim();
    if (q.isEmpty) return;

    setState(() => _loading = true);
    try {
      final res = await widget.tmdb.searchMovies(query: q);
      setState(() => _items = res);
    } catch (e) {
      Get.snackbar('오류', '영화 검색 실패: $e');
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _qCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 12,
        left: 12,
        right: 12,
        bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 44, height: 5, decoration: BoxDecoration(color: const Color(0xFFE8EBF3), borderRadius: BorderRadius.circular(99))),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _qCtrl,
                  decoration: const InputDecoration(
                    hintText: '영화 제목 검색 (예: 인터스텔라)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _loading ? null : _search,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C6BFF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('검색'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 420,
            child: _items.isEmpty
                ? const Center(child: Text('검색어를 입력하고 검색을 눌러주세요'))
                : ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final m = _items[i];
                      final id = m['id'] as int?;
                      final title = (m['title'] ?? m['name'] ?? '').toString();
                      final posterPath = (m['poster_path'] ?? '').toString();
                      final posterUrl = widget.tmdb.imageUrl(posterPath);
                      final genre = _genresText((m['genre_ids'] is List) ? m['genre_ids'] : []);

                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 44,
                            height: 64,
                            color: const Color(0xFFF0F2F6),
                            child: posterUrl.isEmpty
                                ? const Icon(Icons.local_movies_outlined, color: Colors.grey)
                                : Image.network(
                                    posterUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.local_movies_outlined, color: Colors.grey),
                                  ),
                          ),
                        ),
                        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(genre.isEmpty ? '장르 정보 없음' : genre),
                        onTap: () {
                          if (id == null) return;
                          Navigator.pop(
                            context,
                            _MoviePickResult(
                              tmdbId: id,
                              title: title,
                              posterUrl: posterUrl,
                              genre: genre,
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
