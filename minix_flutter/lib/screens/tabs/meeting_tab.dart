import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // 날짜 예쁘게 표시용 (없으면 pub add intl)

import 'package:minix_flutter/controllers/meeting_controller.dart';
import '../../models/meeting_room.dart';
import '../create_meeting_screen.dart';
import '../meeting_detail_screen.dart';

class MeetingTab extends StatelessWidget {
  const MeetingTab({super.key});

  @override
  Widget build(BuildContext context) {
    // 의존성 주입된 컨트롤러 찾기
    final meetingController = Get.find<MeetingController>();
    final Color backgroundColor = const Color(0xFFF5F7FA);

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

      // ✅ [Body] 리스트 상태에 따라 다른 화면 보여주기
      body: Obx(() {
        // 1. 모임이 없을 때 (빈 화면)
        if (meetingController.meetings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.movie_filter_outlined,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 20),
                Text(
                  "아직 생성된 모임이 없어요.\n아래 버튼을 눌러 모임을 만들어보세요!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansKr(
                    color: Colors.grey[500],
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }
        // 2. 모임이 있을 때 (리스트뷰)
        else {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: meetingController.meetings.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final room = meetingController.meetings[index];
              return _MeetingCard(room: room);
            },
          );
        }
      }),

      // 모임 만들기 버튼
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerFloat, // 중앙 하단으로 이동 (우측은 AI버튼과 겹치므로)

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 85), // 👆 하단 네비게이션 바 높이만큼 띄우기
        child: SizedBox(
          height: 42,
          child: FloatingActionButton.extended(
            onPressed: () => Get.to(() => const CreateMeetingScreen()),
            backgroundColor: const Color(0XFF4E73DF),
            elevation: 4,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              "모임 만들기",
              style: GoogleFonts.notoSansKr(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 📌 [카드 위젯] 모임 정보를 보여주는 디자인
class _MeetingCard extends StatelessWidget {
  final MeetingRoom room;
  const _MeetingCard({required this.room});

  @override
  Widget build(BuildContext context) {
    // 날짜 포맷 (intl 패키지 사용)
    String dateStr = DateFormat(
      'M월 d일 (E) HH:mm',
      'ko_KR',
    ).format(room.meetingTime);

    return InkWell(
      onTap: () {
        final passController = TextEditingController();

        Get.defaultDialog(
          title: "비공개 모임", // 이모티콘 제거
          titlePadding: const EdgeInsets.only(top: 24, bottom: 10),
          titleStyle: GoogleFonts.notoSansKr(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          radius: 16,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 10,
          ),

          content: Column(
            children: [
              Text(
                "호스트가 설정한 비밀번호\n4자리를 입력해주세요.",
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansKr(
                  color: Colors.grey[600],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // 입력창 디자인
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: passController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "----", // 점(••••) 대신 하이픈이나 빈칸 추천
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      letterSpacing: 2.0,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),

          // 확인 버튼
          confirm: SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () {
                final meetingController = Get.find<MeetingController>();
                if (meetingController.checkPassword(
                  room,
                  passController.text,
                )) {
                  Get.back();
                  Get.to(() => const MeetingDetailScreen(), arguments: room);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0XFF4E73DF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "입장",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 취소 버튼
          cancel: SizedBox(
            width: 100,
            child: TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text("취소"),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 상태 칩 + 날짜
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0XFF4E73DF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "모집중",
                    style: TextStyle(
                      color: Color(0XFF4E73DF),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  dateStr,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 방 제목
            Text(
              room.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // 영화 정보 & 장소
            Row(
              children: [
                const Icon(Icons.movie_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  room.movieTitle,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    room.theater,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 하단: 참여 인원
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.people_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  "${room.participantIds.length}/${room.maxMembers}명",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}