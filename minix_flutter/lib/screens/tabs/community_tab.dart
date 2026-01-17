import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minix_flutter/controllers/TweetController.dart';
import '../../widgets/tweet_card.dart';
import '../login_screen.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/review_card_from_tweet.dart';


class CommunityTab extends StatelessWidget{
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context){

    final tweetcontroller = Get.find<TweetController>();
    final Color backgroundColor = const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white, // 앱바를 흰색으로 깔끔하게
        elevation: 0, // 그림자 제거
        scrolledUnderElevation: 0, // 스크롤 시 색상 변경 방지
        centerTitle: false, // 타이틀 왼쪽 정렬
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
            icon: const Icon(Icons.person_outline, color: Colors.black87), // 아이콘 색상 통일
            onPressed: () {
              Get.toNamed('/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              Get.offAllNamed('/');
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        //mini: true,
        onPressed: (){
          Get.toNamed('/compose');
        },
        child: const Icon(Icons.edit),
        backgroundColor: const Color.fromARGB(255, 46, 80, 183),
      ),

      // community_tab.dart
// ✅ AppBar는 너의 기존 코드 그대로 두고,
// body만 아래로 교체해줘.

body: Obx(() {
  if (tweetcontroller.isLoading.value) {
    return const Center(child: CircularProgressIndicator());
  }

  return RefreshIndicator(
    onRefresh: () => tweetcontroller.loadTimeline(),
    child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      children: [
        // ✅ 상단 "리뷰" 안내 카드
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🧾', style: TextStyle(fontSize: 18)),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('리뷰',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w900)),
                    SizedBox(height: 4),
                    Text(
                      '별점 + 한줄평 (모임 참여 영화에 연결)',
                      style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.black54,
                          height: 1.2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ✅ 필터 줄 + 작성 버튼 (작성 버튼은 /compose 그대로)
        Row(
          children: [
            _FilterChip(label: '내 리뷰', onTap: () {}),
            const SizedBox(width: 8),
            _FilterChip(label: '모임 리뷰', onTap: () {}),
            const SizedBox(width: 8),
            _FilterChip(label: '취소순', onTap: () {}),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Get.toNamed('/compose'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C6BFF),
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('작성',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ✅ 리스트 컨테이너
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: tweetcontroller.tweets.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('아직 리뷰가 없습니다')),
                )
              : Column(
                  children: List.generate(tweetcontroller.tweets.length, (i) {
                    final tweet = tweetcontroller.tweets[i];
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom:
                              i == tweetcontroller.tweets.length - 1 ? 0 : 12),
                      child: ReviewCardFromTweet(
                        tweet: tweet,
                        onLike: () => tweetcontroller.toggleLike(tweet.id),
                        onDelete: () => tweetcontroller.deleteTweet(tweet.id),
                      ),
                    );
                  }),
                ),
        ),
      ],
    ),
  );
}),




    );
  }
}


class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F7),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

