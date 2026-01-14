import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minix_flutter/controllers/TweetController.dart';
import '../../widgets/tweet_card.dart';
import '../login_screen.dart';
import 'package:google_fonts/google_fonts.dart';


class MeetingTab extends StatelessWidget{
  const MeetingTab({super.key});

  @override
  Widget build(BuildContext context){

    final tweetcontroller = Get.find<TweetController>();
    final Color backgroundColor = const Color(0xFFF5F7FA);

   return Scaffold(
      backgroundColor: backgroundColor, // 배경색 통일
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
    );
  }
}
