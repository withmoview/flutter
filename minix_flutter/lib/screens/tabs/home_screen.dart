import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:minix_flutter/controllers/TweetController.dart';
import 'package:minix_flutter/controllers/main_controller.dart';
import 'package:minix_flutter/services/tmdb_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _pageIndex = 0;
  late final PageController _pageController;
  final _maincontroller = Get.find<MainController>();

  late Future<List<Map<String, dynamic>>> _nowPlayingFuture;
  late Future<List<Map<String, dynamic>>> _popularMovieFuture;

  @override
  void initState() {
    super.initState();

    _pageIndex = 0;
    _pageController = PageController(viewportFraction: 0.90, initialPage: 0);

    final tmdb = Get.find<TmdbService>();
    _nowPlayingFuture = tmdb.getNowPlaying(page: 1, language: 'ko-KR');
    _popularMovieFuture = tmdb.getPopularMovies(page: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // (현재 미사용)
    Get.find<TweetController>();

    return Container(
      color: _kBg,
      child: SafeArea(
        top: true,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Top Header (MeetingTab 스타일로 교체)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  children: [
                    // withmovie pill (MeetingTab 스타일)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black.withOpacity(0.04)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: _kPrimary,
                            ),
                          ),
                          Text(
                            'withmovie',
                            style: GoogleFonts.poppins(
                              color: _kText,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // 프로필 버튼 (MeetingTab 원형 버튼 스타일)
                    _CircleIconButton(
                      icon: Icons.person_outline,
                      onTap: () => _maincontroller.changeTabIndex(3),
                    ),
                    const SizedBox(width: 10),

                    // 로그아웃 버튼 (MeetingTab 원형 버튼 스타일)
                    _CircleIconButton(
                      icon: Icons.logout,
                      iconColor: Colors.redAccent,
                      onTap: () => Get.offAllNamed('/'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ---- 이하 기존 HomeScreen 내용은 그대로 ----
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '최신 영화',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF141A2A),
                      ),
                    ),
                    _GhostTextButton(
                      text: '더보기',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              // ---- PageView (Now Playing) ----
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _nowPlayingFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 420,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

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
                  if (movies.isEmpty) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: Text('표시할 영화가 없습니다.')),
                    );
                  }

                  if (_pageIndex >= movies.length) _pageIndex = 0;

                  return SizedBox(
                    height: 430,
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: movies.length,
                      onPageChanged: (i) => setState(() => _pageIndex = i),
                      itemBuilder: (context, index) {
                        final m = movies[index];

                        final title = (m['title'] ?? m['name'] ?? 'Untitled').toString();
                        final overview = (m['overview'] ?? '').toString();
                        final vote = (m['vote_average'] ?? 0).toDouble();
                        final release = (m['release_date'] ?? '').toString();

                        final posterPath = m['poster_path']?.toString();
                        final posterUrl = (posterPath == null || posterPath.isEmpty)
                            ? null
                            : 'https://image.tmdb.org/t/p/w780$posterPath';

                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Stack(
                            children: [
                              _BigMovieCardPremium(
                                title: title,
                                overview: overview,
                                posterUrl: posterUrl,
                                vote: vote,
                                releaseDate: release,
                                onTap: () {},
                              ),
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

              const SizedBox(height: 22),

              // ---- Popular Section ----
              _HorizontalMovieSectionPremium(
                title: '실시간 인기 영화',
                future: _popularMovieFuture,
                isRanked: true,
              ),

              const SizedBox(height: 18),

              // ---- Quick Menu ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '빠른 메뉴',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF141A2A),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _QuickMenuGrid(
                  items: [
                    _QuickMenuItem(
                      title: '리뷰 작성',
                      subtitle: '내 평점 남기기',
                      icon: Icons.rate_review_outlined,
                      onTap: () {
                        // 예: Get.toNamed('/review/create');
                      },
                    ),
                    _QuickMenuItem(
                      title: '검색',
                      subtitle: '영화 찾기',
                      icon: Icons.search_rounded,
                      onTap: () {
                        // 예: Get.toNamed('/search');
                      },
                    ),
                    _QuickMenuItem(
                      title: '인기',
                      subtitle: '트렌드 보기',
                      icon: Icons.local_fire_department_outlined,
                      onTap: () {
                        // 예: Get.toNamed('/popular');
                      },
                    ),
                    _QuickMenuItem(
                      title: '내 프로필',
                      subtitle: '활동/설정',
                      icon: Icons.person_outline,
                      onTap: () => Get.toNamed('/profile'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ---- 아래 추가 섹션 (추천/큐레이션 느낌) ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '오늘의 추천',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF141A2A),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _PremiumInfoCard(
                  title: '지금 인기 영화로 리뷰를 남겨보세요',
                  description: '좋아하는 작품에 평점/한줄평을 기록하고 타임라인에 공유할 수 있어요.',
                  actionText: '리뷰 쓰기',
                  onTap: () {
                    // 예: Get.toNamed('/review/create');
                  },
                ),
              ),

              const SizedBox(height: 18),

              // ---- 아래 추가 섹션 (내 활동/바로가기 느낌) ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '내 활동',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF141A2A),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: '좋아요',
                        value: '—',
                        icon: Icons.favorite_border,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: '내 리뷰',
                        value: '—',
                        icon: Icons.movie_filter_outlined,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------
 * Premium UI Components
 * ------------------------- */

class _IconPillButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _IconPillButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.92),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor ?? const Color(0xFF222A3A)),
        ),
      ),
    );
  }
}

class _GhostTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _GhostTextButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: GoogleFonts.notoSansKr(
            fontWeight: FontWeight.w800,
            color: const Color(0XFF4E73DF),
          ),
        ),
      ),
    );
  }
}

class _BigMovieCardPremium extends StatelessWidget {
  final String title;
  final String overview;
  final String? posterUrl;
  final double vote;
  final String releaseDate;
  final VoidCallback? onTap;

  const _BigMovieCardPremium({
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
      borderRadius: BorderRadius.circular(26),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
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

                // subtle top vignette (고급스러운 느낌)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Container(
                    height: 120,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x66000000),
                          Color(0x00000000),
                        ],
                      ),
                    ),
                  ),
                ),

                // bottom info
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
                          Color(0xB8000000),
                          Color(0xEE000000),
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
      ),
    );
  }
}

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
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
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

class _HorizontalMovieSectionPremium extends StatelessWidget {
  final String title;
  final Future<List<Map<String, dynamic>>> future;
  final bool isRanked;

  const _HorizontalMovieSectionPremium({
    required this.title,
    required this.future,
    this.isRanked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: GoogleFonts.notoSansKr(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF141A2A),
            ),
          ),
        ),
        SizedBox(
          height: 242,
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
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: movies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final m = movies[index];
                  final posterPath = m['poster_path'];
                  final posterUrl = posterPath != null
                      ? 'https://image.tmdb.org/t/p/w500$posterPath'
                      : null;
                  final title = (m['title'] ?? '제목 없음').toString();

                  return SizedBox(
                    width: 128,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: AspectRatio(
                                  aspectRatio: 2 / 3,
                                  child: posterUrl != null
                                      ? Image.network(posterUrl, fit: BoxFit.cover)
                                      : Container(color: Colors.grey[300]),
                                ),
                              ),
                            ),
                            if (isRanked)
                              Positioned(
                                left: 10,
                                top: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.notoSansKr(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF141A2A),
                            height: 1.25,
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

class _QuickMenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  _QuickMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

class _QuickMenuGrid extends StatelessWidget {
  final List<_QuickMenuItem> items;

  const _QuickMenuGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.85,
      ),
      itemBuilder: (context, i) {
        final it = items[i];
        return _PremiumMenuTile(
          title: it.title,
          subtitle: it.subtitle,
          icon: it.icon,
          onTap: it.onTap,
        );
      },
    );
  }
}

class _PremiumMenuTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _PremiumMenuTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: _kCardDecoration,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _kBg, // ✅ 단색 느낌 (연회색)
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kBorder),
                ),
                child: Icon(icon, color: _kPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: _kText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _kSub,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFB6BDC9)),
            ],
          ),
        ),
      ),
    );
  }
}


class _PremiumInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final String actionText;
  final VoidCallback onTap;

  const _PremiumInfoCard({
    required this.title,
    required this.description,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: _kCardDecoration,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _kBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kBorder),
                ),
                child: const Icon(Icons.auto_awesome, color: _kPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: _kText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _kSub,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _kPrimary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          actionText,
                          style: GoogleFonts.notoSansKr(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: _kCardDecoration,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _kBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kBorder),
                ),
                child: Icon(icon, color: _kPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kSub,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _kText,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFB6BDC9)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _kBorder),
          ),
          child: Icon(icon, color: iconColor ?? _kText),
        ),
      ),
    );
  }
}




const _kBg = Color(0xFFF4F6F8);
const _kCard = Colors.white;
const _kBorder = Color(0xFFE6E8EE);
const _kText = Color(0xFF141A2A);
const _kSub = Color(0xFF6B7280);
const _kPrimary = Color(0xFF4E73DF);

final _kCardDecoration = BoxDecoration(
  color: _kCard,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: _kBorder, width: 1),
);
