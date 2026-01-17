import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../controllers/auth_controller.dart';
import '../controllers/meeting_controller.dart';
import '../models/meeting_room.dart';

class MeetingDetailScreen extends StatelessWidget {
  const MeetingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MeetingRoom room = Get.arguments as MeetingRoom;

    final authController = Get.find<AuthController>();
    final meetingController = Get.find<MeetingController>();

    final myInfo = authController.user.value;
    final myUsername = (myInfo?.username ?? '').trim();

    final isMeHost = room.hostId.trim() == myUsername;
    final isMeParticipant = meetingController.isParticipant(room);

    final dateStr = DateFormat('M월 d일 (E) HH:mm', 'ko_KR').format(room.meetingTime);
    final posterUrl = room.moviePosterUrl;

    // 버튼/상태
    final canEnterChat = isMeParticipant; // 참가자만 채팅 가능(서버도 참가자 체크)
    final canLeave = isMeParticipant && !isMeHost;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "모임 상세",
          style: GoogleFonts.notoSansKr(
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
          if (isMeHost)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                Get.defaultDialog(
                  title: "모임 삭제",
                  middleText: "정말로 모임을 삭제하시겠습니까?\n삭제된 모임은 복구할 수 없습니다.",
                  textConfirm: "삭제",
                  confirmTextColor: Colors.white,
                  buttonColor: Colors.red,
                  textCancel: "취소",
                  onConfirm: () async {
                    final id = room.id;
                    if (id == null || id.isEmpty) {
                      Get.back();
                      Future.delayed(const Duration(milliseconds: 80), () {
                        if (Get.isSnackbarOpen == true) Get.closeAllSnackbars();
                        Get.snackbar("오류", "방 ID가 없어 삭제할 수 없습니다.",
                            snackPosition: SnackPosition.BOTTOM);
                      });
                      return;
                    }

                    if (Get.isSnackbarOpen == true) Get.closeAllSnackbars();

                    final ok = await meetingController.deleteMeeting(id);

                    Get.back(); // dialog
                    if (ok) {
                      Get.back(); // screen
                      Future.delayed(const Duration(milliseconds: 120), () {
                        Get.snackbar("삭제 완료", "모임이 삭제되었습니다.",
                            snackPosition: SnackPosition.BOTTOM);
                      });
                    } else {
                      Future.delayed(const Duration(milliseconds: 120), () {
                        Get.snackbar("오류", "삭제에 실패했습니다.",
                            snackPosition: SnackPosition.BOTTOM);
                      });
                    }
                  },
                );
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 포스터 영역
            SizedBox(
              width: double.infinity,
              height: 260,
              child: posterUrl == null
                  ? Container(
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.movie_creation_outlined,
                              size: 60, color: Colors.grey),
                          const SizedBox(height: 10),
                          Text(
                            room.movieTitle,
                            style: GoogleFonts.notoSansKr(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          posterUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.broken_image,
                                  size: 48, color: Colors.grey),
                            ),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x15000000), Color(0xB0000000)],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Text(
                            room.movieTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.notoSansKr(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _infoRow(Icons.calendar_today, dateStr),
                  const SizedBox(height: 12),
                  _infoRow(Icons.location_on_outlined, room.theater),
                  const SizedBox(height: 12),
                  _infoRow(
                    Icons.person_outline,
                    isMeHost
                        ? "호스트: ${(myUsername.isEmpty ? room.hostId : myUsername)} (나)"
                        : "호스트: ${room.hostId}",
                  ),

                  const Divider(height: 40, thickness: 1),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "참여 멤버 (${room.participantIds.length}/${room.maxMembers})",
                        style: GoogleFonts.notoSansKr(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      // ✅ (옵션) 방장만: 강퇴 기능 자리(서버 필요)
                      if (isMeHost)
                        Text(
                          "방장 기능",
                          style: GoogleFonts.notoSansKr(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.black45,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: room.participantIds.map((name) {
                        final n = name.trim();
                        final isMe = (myUsername.isNotEmpty && n == myUsername);
                        final isHost = (n == room.hostId);

                        final avatarText =
                            (n.isNotEmpty ? n[0] : 'G').toUpperCase();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0XFF4E73DF),
                                child: Text(
                                  avatarText,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isMe ? "$n (나)" : n,
                                  style: GoogleFonts.notoSansKr(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              if (isHost)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: Colors.grey.shade300),
                                  ),
                                  child: Text(
                                    "방장",
                                    style: GoogleFonts.notoSansKr(
                                      fontSize: 11,
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),

                              // ✅ (옵션) 방장 강퇴 버튼 UI (서버 API 추가되면 연결)
                              if (isMeHost && !isHost)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: TextButton(
                                    onPressed: () {
                                      Get.snackbar(
                                        "안내",
                                        "강퇴 기능은 서버 API 추가 후 연결됩니다.",
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.redAccent,
                                    ),
                                    child: const Text("강퇴"),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ✅ 하단: 참가/채팅/나가기 상태에 맞게 구성
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1) 메인 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (Get.isSnackbarOpen == true) Get.closeAllSnackbars();

                    if (!isMeParticipant) {
                      // ✅ 참가하기: 비밀번호 입력 다이얼로그
                      final pw = await _askPassword();
                      if (pw == null) return;

                      final updated = await meetingController.joinMeeting(
                        room: room,
                        password: pw,
                      );

                      if (updated != null) {
                        // 화면 갱신을 위해 재진입(간단/확실한 방법)
                        Get.offNamed(Get.currentRoute, arguments: updated);
                        Get.snackbar("완료", "모임에 참가했습니다.",
                            snackPosition: SnackPosition.BOTTOM);
                      }
                      return;
                    }

                    // ✅ 참가자면 채팅 진입
                    if (canEnterChat) {
                      Get.toNamed('/meeting/chat', arguments: room);
                      return;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0XFF4E73DF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    !isMeParticipant ? "참가하기" : "채팅방 입장하기",
                    style: GoogleFonts.notoSansKr(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

              // 2) 보조 버튼: 나가기 (참가자 & 방장 아님)
              if (canLeave) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.defaultDialog(
                        title: "모임 나가기",
                        middleText: "정말로 모임에서 나가시겠습니까?",
                        textConfirm: "나가기",
                        confirmTextColor: Colors.white,
                        buttonColor: Colors.redAccent,
                        textCancel: "취소",
                        onConfirm: () async {
                          Get.back(); // dialog close

                          final ok = await meetingController.leaveMeeting(room: room);
                          if (ok) {
                            // 목록 화면이 있다면 거기서 새로고침되게 하고 싶으면:
                            // meetingController.loadMeetings();
                            Get.back(); // detail close
                          }
                        },
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.redAccent.withOpacity(0.8)),
                    ),
                    child: Text(
                      "모임 나가기",
                      style: GoogleFonts.notoSansKr(
                        fontSize: 14,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _askPassword() async {
    final ctrl = TextEditingController();

    String? result;

    await Get.defaultDialog(
      title: "비밀번호 입력",
      middleText: "모임 비밀번호(숫자 4자리)를 입력해주세요.",
      content: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: "예) 1234",
            border: OutlineInputBorder(),
            counterText: "",
          ),
        ),
      ),
      textCancel: "취소",
      textConfirm: "확인",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0XFF4E73DF),
      onConfirm: () {
        final pw = ctrl.text.trim();
        if (!RegExp(r'^\d{4}$').hasMatch(pw)) {
          Get.snackbar("알림", "비밀번호는 숫자 4자리여야 합니다.",
              snackPosition: SnackPosition.BOTTOM);
          return;
        }
        result = pw;
        Get.back();
      },
    );

    ctrl.dispose();
    return result;
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.notoSansKr(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
