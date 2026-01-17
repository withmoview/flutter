import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:minix_flutter/controllers/meeting_controller.dart';
import '../models/meeting_room.dart';
import '../controllers/auth_controller.dart'; // ✅ AuthController import 필수

class MeetingDetailScreen extends StatelessWidget {
  const MeetingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. 리스트에서 넘겨준 방 정보 받기
    final MeetingRoom room = Get.arguments;

    // 2. AuthController를 통해 내 정보 가져오기
    final authController = Get.find<AuthController>();
    final myInfo = authController.user.value;

    //삭제 기능을 위한 meetingcontroller
    final _meetingController =  Get.find<MeetingController>();

    // 3. 내가 이 방의 호스트인지 확인 (아이디 혹은 유저네임 비교)
    // room.hostId가 유저의 username과 같다고 가정
    bool isMeHost = room.hostId == (myInfo?.username ?? ''); 

    String dateStr = DateFormat('M월 d일 (E) HH:mm', 'ko_KR').format(room.meetingTime);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "모임 상세",
          style: GoogleFonts.notoSansKr(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {}, 
          ),

          if (isMeHost)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: (){
                Get.defaultDialog(
                  title: "모임 삭제",
                  middleText: "정말로 모임을 삭제하시겠습니까?\n삭제된 모임은 복구할 수 없습니다",
                  textConfirm: "삭제",
                  confirmTextColor: Colors.white,
                  buttonColor: Colors.red,
                  textCancel: "취소",
                  onConfirm: (){
                    _meetingController.deleteMeeting(room.id!);
                    Get.back();
                  }
                );
              },
            ),
            const SizedBox(width: 8,),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 영화 포스터 영역
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.movie_creation_outlined, size: 60, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(room.movieTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. 방 제목
                  Text(
                    room.title,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. 정보 리스트 (장소, 시간)
                  _infoRow(Icons.calendar_today, dateStr),
                  const SizedBox(height: 12),
                  _infoRow(Icons.location_on_outlined, room.theater),
                  const SizedBox(height: 12),
                  
                  // ✅ 호스트 정보 표시 (내가 호스트면 내 이름 표시)
                  _infoRow(
                    Icons.person_outline, 
                    isMeHost 
                        ? "호스트: ${myInfo?.username} (나)" 
                        : "호스트: ${room.hostId}"
                  ),

                  const Divider(height: 40, thickness: 1),

                  // 4. 참여자 목록 타이틀
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("참여 멤버 (${room.participantIds.length}/${room.maxMembers})", 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // ✅ 참여자 리스트 (내 정보 실제 데이터 바인딩)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0XFF4E73DF),
                          // 이름의 첫 글자를 따서 아바타에 표시 (예: J)
                          child: Text(
                            (myInfo?.username ?? "Guest").substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ 실제 내 닉네임
                            Text(
                              "${myInfo?.username ?? '알 수 없음'} (나)", 
                              style: const TextStyle(fontWeight: FontWeight.bold)
                            ),
                            // 내가 호스트일 때만 '방장' 텍스트 표시 (옵션)
                            if (isMeHost)
                              const Text("모임장", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        const Spacer(),
                        
                        // ✅ 내가 호스트면 '방장' 뱃지 표시
                        if (isMeHost)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Text("방장", style: TextStyle(fontSize: 11, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // 하단: 채팅방 입장 버튼
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              // TODO: 채팅 화면으로 이동
              Get.snackbar("알림", "곧 채팅 기능이 추가됩니다!");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0XFF4E73DF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("채팅방 입장하기", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 15, color: Colors.black87)),
      ],
    );
  }
}