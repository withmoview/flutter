import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:minix_flutter/controllers/TweetController.dart';
import 'package:minix_flutter/services/tmdb_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _pageIndex = 0;

  late final PageController _pageController;

  // ✅ 핵심: Future를 build에서 만들지 말고 initState에서 1번만 생성(캐시)
  late Future<List<Map<String, dynamic>>> _nowPlayingFuture;

  @override
  void initState() {
    super.initState();

    _pageIndex = 0;
    _pageController = PageController(viewportFraction: 0.92, initialPage: 0);

    // Get.find는 initState에서도 가능(단, main에서 put이 먼저 되어있어야 함)
    final tmdb = Get.find<TmdbService>();
    _nowPlayingFuture = tmdb.getNowPlaying(page: 1, language: 'ko-KR');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 유지용(아직 안 써도 OK)
    final tweetController = Get.find<TweetController>();

    const backgroundColor = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          'withmovie',
          style: GoogleFonts.dancingScript(
            color: const Color(0XFF4E73DF),
            fontWeight: FontWeight.w700,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87),
            onPressed: () => Get.toNamed('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => Get.offAllNamed('/'),
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== 섹션 헤더 =====
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최신 영화',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {}, // 나중에 더보기
                  child: Text(
                    '더보기',
                    style: GoogleFonts.notoSansKr(
                      fontWeight: FontWeight.w800,
                      color: const Color(0XFF4E73DF),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===== PageView =====
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _nowPlayingFuture, // ✅ 캐시된 Future 사용
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '영화 불러오기 실패: ${snapshot.error}',
                        style: GoogleFonts.notoSansKr(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }

              final movies = snapshot.data ?? [];
              if (movies.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Text(
                      '표시할 영화가 없어요.',
                      style: GoogleFonts.notoSansKr(color: Colors.black54),
                    ),
                  ),
                );
              }

              // 안전 보정
              if (_pageIndex >= movies.length) _pageIndex = 0;

              return Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 6),

                    SizedBox(
                      height: 420,
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const PageScrollPhysics(), // ✅ 스와이프 OK
                        itemCount: movies.length,
                        onPageChanged: (i) => setState(() => _pageIndex = i),
                        itemBuilder: (context, index) {
                          final m = movies[index];

                          final title = (m['title'] ?? m['name'] ?? 'Untitled').toString();
                          final overview = (m['overview'] ?? '').toString();
                          final vote = (m['vote_average'] ?? 0).toDouble();
                          final release = (m['release_date'] ?? '').toString();

                          final posterPath = m['poster_path']?.toString();
                          final posterUrl = (posterPath == null || posterPath == 'null' || posterPath.isEmpty)
                              ? null
                              : 'https://image.tmdb.org/t/p/w780$posterPath';

                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Stack(
                              children: [
                                // 카드 본체
                                _BigMovieCard(
                                  title: title,
                                  overview: overview,
                                  posterUrl: posterUrl,
                                  vote: vote,
                                  releaseDate: release,
                                  onTap: () {
                                    // TODO 상세 이동
                                  },
                                ),

                                // ✅ 우상단 숫자 배지 (현재/전체)
                                Positioned(
                                  right: 14,
                                  top: 14,
                                  child: _TopRightCounterBadge(
                                    text: '${index + 1} / ${movies.length}',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 카드
class _BigMovieCard extends StatelessWidget {
  final String title;
  final String overview;
  final String? posterUrl;
  final double vote;
  final String releaseDate;
  final VoidCallback? onTap;

  const _BigMovieCard({
    required this.title,
    required this.overview,
    required this.posterUrl,
    required this.vote,
    required this.releaseDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned.fill(
                child: posterUrl == null
                    ? Container(
                        color: const Color(0xFFE9EEF5),
                        child: const Center(
                          child: Icon(Icons.movie, size: 52, color: Colors.black38),
                        ),
                      )
                    : Image.network(
                        posterUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFE9EEF5),
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 52, color: Colors.black38),
                          ),
                        ),
                      ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00000000),
                        Color(0xB0000000),
                        Color(0xE0000000),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 18, color: Color(0xFFFFC107)),
                          const SizedBox(width: 6),
                          Text(
                            vote.toStringAsFixed(1),
                            style: GoogleFonts.notoSansKr(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (releaseDate.isNotEmpty)
                            Text(
                              releaseDate,
                              style: GoogleFonts.notoSansKr(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      if (overview.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          overview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.notoSansKr(
                            color: Colors.white70,
                            fontSize: 12.5,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ✅ 우상단 카운터 배지
class _TopRightCounterBadge extends StatelessWidget {
  final String text;

  const _TopRightCounterBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withOpacity(0.22)),
        ),
        child: Text(
          text,
          style: GoogleFonts.notoSansKr(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}
