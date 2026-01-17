import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:minix_flutter/controllers/TweetController.dart';
import 'package:minix_flutter/controllers/main_controller.dart';
import 'package:minix_flutter/controllers/auth_controller.dart';
import '../../widgets/review_card_from_tweet.dart';

/// KakaoBank-ish flat style tokens (MeetingTab과 통일)
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

class CommunityTab extends StatelessWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tweetController = Get.find<TweetController>();
    final mainController = Get.find<MainController>();
    final authController = Get.find<AuthController>();

    return Container(
      color: _kBg,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            // ✅ 헤더를 AppBar 대신 직접 구성(짤림 방지)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // withmovie pill
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
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _kPrimary,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
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

                      // 프로필(마이 탭으로)
                      _CircleIconButton(
                        icon: Icons.person_outline,
                        onTap: () => mainController.changeTabIndex(3),
                      ),
                      const SizedBox(width: 10),

                      // ✅ 상단 아이콘을 로그아웃으로 변경(편집 아이콘 제거)
                      _CircleIconButton(
                        icon: Icons.logout,
                        iconColor: Colors.redAccent,
                        onTap: () {
                          authController.logout();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Text(
                    '커뮤니티',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _kText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '리뷰를 공유하고 서로의 취향을 알아보세요.',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: _kSub,
                    ),
                  ),
                ],
              ),
            ),

            // ✅ 본문
            Expanded(
              child: Obx(() {
                if (tweetController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return RefreshIndicator(
                  onRefresh: () => tweetController.loadTimeline(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                    children: [
                      // 상단 안내 카드
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: _kCardDecoration,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _kBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _kBorder),
                              ),
                              child: const Center(
                                child: Text('🧾', style: TextStyle(fontSize: 18)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '리뷰',
                                    style: GoogleFonts.notoSansKr(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: _kText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '평점과 한줄평을 기록하고 공유해보세요.',
                                    style: GoogleFonts.notoSansKr(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _kSub,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 필터/정렬 줄 (UI만)
                      Row(
                        children: [
                          _FilterChip(label: '최신순', onTap: () {}),
                          const SizedBox(width: 8),
                          _FilterChip(label: '좋아요순', onTap: () {}),
                          const SizedBox(width: 8),
                          _FilterChip(label: '내 리뷰', onTap: () {}),
                          const Spacer(),

                          // ✅ 파란 작성 버튼은 그대로 유지
                          _PrimaryButton(
                            text: '작성',
                            onTap: () => Get.toNamed('/compose'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // 리스트 컨테이너
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: _kCardDecoration,
                        child: tweetController.tweets.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: Text(
                                    '아직 리뷰가 없습니다',
                                    style: GoogleFonts.notoSansKr(
                                      color: _kSub,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children: List.generate(tweetController.tweets.length, (i) {
                                  final tweet = tweetController.tweets[i];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: i == tweetController.tweets.length - 1 ? 0 : 12,
                                    ),
                                    child: ReviewCardFromTweet(
                                      tweet: tweet,
                                      onLike: () => tweetController.toggleLike(tweet.id),
                                      onDelete: () => tweetController.deleteTweet(tweet.id),
                                    ),
                                  );
                                }),
                              ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _kBorder),
          ),
          child: Text(
            label,
            style: GoogleFonts.notoSansKr(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: _kText,
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _PrimaryButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _kPrimary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            text,
            style: GoogleFonts.notoSansKr(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = _kText,
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
          child: Icon(icon, color: iconColor),
        ),
      ),
    );
  }
}
