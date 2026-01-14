import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minix_flutter/models/tweet.dart';
import 'package:minix_flutter/screens/webview_screen.dart';

import '../controllers/auth_controller.dart';
import '../services/api_service.dart';
import '../widgets/tweet_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authController = Get.find<AuthController>();
  final _api = Get.find<ApiService>();

  List<Tweet> _myTweets = []; // 내 트윗 목록
  bool _isLoading = true; // 로딩 상태

  // ★ 디자인 테마 컬러 (로그인 화면과 통일)
  final Color _primaryColor = const Color(0xFF4E73DF);
  final Color _backgroundColor = const Color(0xFFF5F7FA); // 아주 연한 회색 배경

  @override
  void initState() {
    super.initState();
    _loadData(); // 화면 진입시 데이터 로드
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 서버에서 내 트윗 목록 가져오기
      final tweetsData = await _api.getMyTweets();
      _myTweets = (tweetsData as List)
          .map((json) => Tweet.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      Get.snackbar('오류', '데이터 로드 실패');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor, // 배경색 변경
      appBar: AppBar(
        title: const Text(
          '프로필',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // 앱바 그림자 제거 (깔끔하게)
        centerTitle: true,
        actions: [
          // 로그아웃 버튼 (스타일 개선)
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => _authController.logout(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      final user = _authController.user.value;
      if (user == null) return const SizedBox();

      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 1. 프로필 카드 섹션 (하얀색 박스 안에 정보 담기)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 프로필 이미지 (그림자 추가)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 45, // 크기 살짝 조정
                      backgroundColor: _primaryColor,
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 이름
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 사용자명
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 내 트윗 개수 & 이용약관 (가로로 배치하여 공간 절약)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 트윗 개수 표시
                      _buildInfoItem(
                        count: _myTweets.length.toString(),
                        label: "내 트윗",
                      ),
                      // 구분선
                      Container(height: 30, width: 1, color: Colors.grey[300]),
                      // 이용약관 버튼
                      TextButton(
                        onPressed: () {
                          Get.to(() => const WebViewScreen(
                                title: '이용약관',
                                url: 'https://banawy.store',
                              ));
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                        ),
                        child: const Column(
                          children: [
                             Icon(Icons.description_outlined, size: 22),
                             SizedBox(height: 4),
                             Text("이용약관", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. 리스트 헤더
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "최근 활동",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),

            // 3. 내 트윗 목록
            if (_myTweets.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.article_outlined, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 10),
                      Text(
                        '작성한 트윗이 없습니다',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(), // 스크롤은 전체 화면이 담당
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                itemCount: _myTweets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12), // 카드 사이 간격
                itemBuilder: (context, index) {
                  // 트윗 카드 스타일도 살짝 감싸줌
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TweetCard(
                      tweet: _myTweets[index],
                      onLike: () {},
                      onDelete: () {},
                    ),
                  );
                },
              ),
            const SizedBox(height: 40), // 하단 여백
          ],
        ),
      );
    });
  }

  // 통계 아이템 위젯 (숫자 + 라벨)
  Widget _buildInfoItem({required String count, required String label}) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}