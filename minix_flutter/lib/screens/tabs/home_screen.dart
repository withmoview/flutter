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

  // 데이터 캐싱을 위한 Future 변수
  late Future<List<Map<String, dynamic>>> _nowPlayingFuture;
  late Future<List<Map<String, dynamic>>> _poppularMoviewFuture;

  @override
  void initState() {
    super.initState();

    _pageIndex = 0;
    _pageController = PageController(viewportFraction: 0.92, initialPage: 0);

    // API 호출은 initState에서 한 번만 실행
    final tmdb = Get.find<TmdbService>();
    _nowPlayingFuture = tmdb.getNowPlaying(page: 1, language: 'ko-KR');
    _poppularMoviewFuture = tmdb.getPopularMovies(page: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 컨트롤러 필요 시 사용 (현재는 미사용)
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
          style: GoogleFonts.poppins(
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

      // 스크롤 가능한 구조로 변경 (SingleChildScrollView)
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 상단 타이틀 영역
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
                    onPressed: () {}, // 더보기 기능 구현 필요
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

            // 2. 영화 카드 슬라이더 영역
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _nowPlayingFuture,
              builder: (context, snapshot) {
                // 로딩 상태
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 420,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // 에러 상태
                if (snapshot.hasError) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        '영화 불러오기 실패: ${snapshot.error}',
                        style: GoogleFonts.notoSansKr(color: Colors.redAccent),
                      ),
                    ),
                  );
                }

                final movies = snapshot.data ?? [];

                // movies.sort((a, b) {
                //   final dateA = a['release_date'] ?? '';
                //   final dateB = b['release_date'] ?? '';
                //   // 날짜(String) 비교: B가 A보다 크면(최신이면) 앞으로 보냄
                //   return dateB.compareTo(dateA);
                // });

                // 데이터 없음 상태
                if (movies.isEmpty) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: Text('표시할 영화가 없습니다.')),
                  );
                }

                if (_pageIndex >= movies.length) _pageIndex = 0;

                // 데이터 표출
                return SizedBox(
                  height: 420, // 높이 고정 필수
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const PageScrollPhysics(),
                    itemCount: movies.length,
                    onPageChanged: (i) => setState(() => _pageIndex = i),
                    itemBuilder: (context, index) {
                      final m = movies[index];

                      final title = (m['title'] ?? m['name'] ?? 'Untitled')
                          .toString();
                      final overview = (m['overview'] ?? '').toString();
                      final vote = (m['vote_average'] ?? 0).toDouble();
                      final release = (m['release_date'] ?? '').toString();

                      final posterPath = m['poster_path']?.toString();
                      final posterUrl =
                          (posterPath == null || posterPath.isEmpty)
                          ? null
                          : 'https://image.tmdb.org/t/p/w780$posterPath';

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Stack(
                          children: [
                            // 카드 UI 위젯
                            _BigMovieCard(
                              title: title,
                              overview: overview,
                              posterUrl: posterUrl,
                              vote: vote,
                              releaseDate: release,
                              onTap: () {
                                // 상세 페이지 이동 로직 추가
                              },
                            ),
                            // 우측 상단 카운터 배지
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
                );
              },
            ),

            const SizedBox(height: 30), // 간격 띄우기

            _HorizontalMovieSection(
              title: "실시간 인기 영화",
               future: _poppularMoviewFuture,
               isRanked: true,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '빠른 메뉴',
                style: GoogleFonts.notoSansKr(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            Container(
              height: 150,
              margin: const EdgeInsets.all(16),
              color: Colors.grey[200],
              child: const Center(child: Text('빠른 메뉴 공간')),
            ),

            const SizedBox(height: 110), // 하단 여백
          ],
        ),
        
      ),
    );
  }
}

// 영화 정보 카드 위젯
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
              // 배경 이미지
              Positioned.fill(
                child: posterUrl == null
                    ? Container(
                        color: const Color(0xFFE9EEF5),
                        child: const Center(
                          child: Icon(
                            Icons.movie,
                            size: 52,
                            color: Colors.black38,
                          ),
                        ),
                      )
                    : Image.network(
                        posterUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFE9EEF5),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 52,
                              color: Colors.black38,
                            ),
                          ),
                        ),
                      ),
              ),

              // 하단 정보 그라데이션 영역
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
                          const Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: Color(0xFFFFC107),
                          ),
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

// 우측 상단 카운터 배지 위젯
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

/// 가로 스크롤 영화 섹션 위젯
class _HorizontalMovieSection extends StatelessWidget {
  final String title;
  final Future<List<Map<String, dynamic>>> future;
  final bool isRanked; // 순위 표시 여부

  const _HorizontalMovieSection({
    required this.title,
    required this.future,
    this.isRanked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 제목
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: GoogleFonts.notoSansKr(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        
        // 가로 리스트 (FutureBuilder)
        SizedBox(
          height: 240, // 포스터(180) + 텍스트 공간 확보
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Text("로드 실패"));
              }

              final movies = snapshot.data!;

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal, // ✅ 가로 스크롤 핵심
                itemCount: movies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14), // 아이템 간격
                itemBuilder: (context, index) {
                  final m = movies[index];
                  final posterPath = m['poster_path'];
                  final posterUrl = posterPath != null 
                      ? 'https://image.tmdb.org/t/p/w500$posterPath' 
                      : null;
                  final title = m['title'] ?? '제목 없음';

                  return SizedBox(
                    width: 120, // 포스터 너비
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 포스터 이미지 + (옵션) 순위 배지
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AspectRatio(
                                aspectRatio: 2 / 3, // 포스터 비율
                                child: posterUrl != null
                                    ? Image.network(posterUrl, fit: BoxFit.cover)
                                    : Container(color: Colors.grey[300]),
                              ),
                            ),
                            
                            // ✅ 순위 표시 (isRanked가 true일 때만)
                            if (isRanked)
                              Positioned(
                                left: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.only(top: 4, right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: GoogleFonts.dancingScript( // 숫자 폰트 멋지게
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      height: 1.0, 
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // 영화 제목
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.notoSansKr(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}