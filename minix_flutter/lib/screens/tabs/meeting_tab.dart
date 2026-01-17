import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:minix_flutter/controllers/meeting_controller.dart';
import 'package:minix_flutter/controllers/main_controller.dart';

import '../../models/meeting_room.dart';
import '../create_meeting_screen.dart';
import '../meeting_detail_screen.dart';

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

class MeetingTab extends StatelessWidget {
  const MeetingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final meetingController = Get.find<MeetingController>();
    final mainController = Get.find<MainController>();

    return Container(
      color: _kBg,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
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
                      _CircleIconButton(
                        icon: Icons.person_outline,
                        onTap: () => mainController.changeTabIndex(3),
                      ),
                      const SizedBox(width: 10),
                      _CircleIconButton(
                        icon: Icons.add,
                        onTap: () => Get.to(() => const CreateMeetingScreen()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '모임',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _kText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '영화 보고 같이 이야기할 사람을 찾아보세요.',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: _kSub,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Obx(() {
                if (meetingController.isLoading.value && meetingController.meetings.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (meetingController.meetings.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: meetingController.loadMeetings,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: meetingController.meetings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final room = meetingController.meetings[index];
                      return _MeetingCard(room: room);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _kBorder),
              ),
              child: const Icon(
                Icons.movie_filter_outlined,
                size: 42,
                color: Color(0xFFB6BDC9),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "아직 생성된 모임이 없습니다.",
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansKr(
                color: _kText,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "우측 상단 + 버튼으로 모임을 만들어주세요.",
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansKr(
                color: _kSub,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final MeetingRoom room;
  const _MeetingCard({required this.room});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('M월 d일 (E) HH:mm', 'ko_KR').format(room.meetingTime);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openPasswordDialog(room),
        child: Ink(
          decoration: _kCardDecoration,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _StatusChip(text: "모집중"),
                  Text(
                    dateStr,
                    style: GoogleFonts.notoSansKr(
                      color: _kSub,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                room.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.notoSansKr(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _kText,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(Icons.movie_outlined, size: 16, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      room.movieTitle,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _kText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      room.theater,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _kText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(Icons.people_outline, size: 16, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 6),
                  Text(
                    "${room.participantIds.length}/${room.maxMembers}명",
                    style: GoogleFonts.notoSansKr(
                      color: _kSub,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFFB6BDC9)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPasswordDialog(MeetingRoom room) {
    final passController = TextEditingController();

    Get.defaultDialog(
      title: "비공개 모임",
      titlePadding: const EdgeInsets.only(top: 22, bottom: 10),
      titleStyle: GoogleFonts.notoSansKr(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: _kText,
      ),
      radius: 16,
      contentPadding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
      content: Column(
        children: [
          Text(
            "호스트가 설정한 비밀번호 4자리를 입력해주세요.",
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansKr(
              color: _kSub,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
            ),
            child: TextField(
              controller: passController,
              obscureText: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: _kText,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "----",
                hintStyle: GoogleFonts.poppins(
                  color: const Color(0xFF9CA3AF),
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w600,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
      confirm: SizedBox(
        width: 110,
        child: ElevatedButton(
          onPressed: () async {
            final meetingController = Get.find<MeetingController>();

            final updated = await meetingController.joinMeeting(
              room: room,
              password: passController.text,
            );

            if (updated != null) {
              Get.back(); // dialog close
              Get.to(() => const MeetingDetailScreen(), arguments: updated);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _kPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text("입장", style: GoogleFonts.notoSansKr(fontWeight: FontWeight.w800)),
        ),
      ),
      cancel: SizedBox(
        width: 110,
        child: OutlinedButton(
          onPressed: () => Get.back(),
          style: OutlinedButton.styleFrom(
            foregroundColor: _kSub,
            side: const BorderSide(color: _kBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text("취소", style: GoogleFonts.notoSansKr(fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  const _StatusChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFDDE3FF)),
      ),
      child: Text(
        text,
        style: GoogleFonts.notoSansKr(
          color: _kPrimary,
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
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
          child: Icon(icon, color: _kText),
        ),
      ),
    );
  }
}
