import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minix_flutter/models/tweet.dart';
import 'package:minix_flutter/screens/webview_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // 디자인 테마 컬러
  final Color _primaryColor = const Color(0xFF4E73DF);
  final Color _backgroundColor = const Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 데이터 로드 (내 트윗 목록)
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final tweetsData = await _api.getMyTweets();
      _myTweets = (tweetsData as List)
          .map((json) => Tweet.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      Get.snackbar('오류', '데이터 로드 실패');
    }
    setState(() => _isLoading = false);
  }

  // 프로필 이미지 변경 로직
  Future<void> _changeProfileImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
    );

    if (image == null) return;

    try {
      // 1. 파일 업로드
      final fileId = await _api.uploadImage(image);
      if (fileId == null) {
        Get.snackbar('오류', '이미지 업로드에 실패했습니다');
        return;
      }

      // 2. 프로필 정보 업데이트
      final success = await _api.updateProfile(profileImageId: fileId);
      if (success != null) {
        Get.snackbar('완료', '프로필 이미지가 변경되었습니다');
        await _authController.loadProfile(); // 최신 정보 갱신
      }
    } catch (e) {
      Get.snackbar('오류', '프로필 수정에 실패했습니다');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: const Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.w700,
            fontSize: 28,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
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

            // 1. 프로필 카드 섹션
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
                  // 프로필 이미지 및 카메라 버튼
                  Stack(
                    children: [
                      // 기존 이미지 영역
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
                          radius: 45,
                          backgroundImage: user.profile_image_id != null
                              ? NetworkImage(
                                  _api.getImageUrl(user.profile_image_id!))
                              : null,
                          backgroundColor: _primaryColor,
                          child: user.profile_image_id == null
                              ? Text(
                                  user.name.isNotEmpty
                                      ? user.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      // 카메라 버튼
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _changeProfileImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[200]!),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ],
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

                  // 사용자 아이디
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 통계 및 약관
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 트윗 개수
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

            // 3. 내 트윗 목록 리스트
            if (_myTweets.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.article_outlined,
                          size: 48, color: Colors.grey[300]),
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
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                itemCount: _myTweets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
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

  // 통계 아이템 위젯
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