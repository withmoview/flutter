// lib/screens/create_meeting_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:minix_flutter/controllers/meeting_controller.dart';
import 'movie_search_screen.dart';

/// MeetingTab과 같은 KakaoBank-ish 토큰
const _kBg = Color(0xFFF4F6F8);
const _kCard = Colors.white;
const _kBorder = Color(0xFFE6E8EE);
const _kText = Color(0xFF141A2A);
const _kSub = Color(0xFF6B7280);
const _kPrimary = Color(0xFF4E73DF);

class CreateMeetingScreen extends StatelessWidget {
  const CreateMeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 여기서 put 금지! (중복 생성/상태 꼬임 방지)
    final controller = Get.find<MeetingController>();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: Text(
          '모임 만들기',
          style: GoogleFonts.notoSansKr(
            fontWeight: FontWeight.w800,
            color: _kText,
          ),
        ),
        backgroundColor: _kBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _kText),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('모임 제목'),
            _buildTextField(
              controller: controller.titleController,
              hint: '예: 이번 주말 듄2 보러 가실 분',
              icon: Icons.campaign_outlined,
            ),
            const SizedBox(height: 18),

            // ✅ 영화 선택
            _buildLabel('영화 선택'),
            Obx(() {
              final title = controller.movieController.text.trim();
              final posterPath = controller.selectedMoviePosterPath.value.trim();
              final posterUrl =
                  posterPath.isEmpty ? null : 'https://image.tmdb.org/t/p/w500$posterPath';

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  final result = await Get.to(() => const MovieSearchScreen());
                  if (result == null) return;

                  int? id;
                  String? pickedTitle;
                  String? pickedPosterPath;

                  if (result is MoviePickResult) {
                    id = result.id;
                    pickedTitle = result.title;
                    pickedPosterPath = result.posterPath;
                  } else if (result is Map) {
                    final rawId = result['id'];
                    id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
                    pickedTitle = result['title']?.toString();
                    pickedPosterPath =
                        result['posterPath']?.toString() ?? result['poster_path']?.toString();
                  }

                  if (id == null || (pickedTitle ?? '').trim().isEmpty) {
                    _safeSnack('오류', '영화 선택 데이터를 읽지 못했습니다.');
                    return;
                  }

                  controller.setSelectedMovie(
                    movieId: id,
                    title: pickedTitle!.trim(),
                    posterPath: pickedPosterPath,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: _kCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kBorder),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: 46,
                          height: 64,
                          child: posterUrl == null
                              ? Container(
                                  color: const Color(0xFFF1F3F7),
                                  child: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                                )
                              : Image.network(
                                  posterUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFFF1F3F7),
                                    child: const Icon(Icons.broken_image, color: Color(0xFF9CA3AF)),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title.isEmpty ? '영화를 검색해서 선택하세요' : title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.notoSansKr(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: title.isEmpty ? const Color(0xFF9CA3AF) : _kText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Color(0xFFB6BDC9)),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 18),

            _buildLabel('상영관 / 장소'),
            _buildTextField(
              controller: controller.theaterController,
              hint: '예: CGV 용산아이파크몰',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 18),

            // 날짜 & 시간
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('날짜'),
                      Obx(() => _buildPickerButton(
                            text: controller.selectedDate.value == null
                                ? '날짜 선택'
                                : '${controller.selectedDate.value!.year}-${controller.selectedDate.value!.month.toString().padLeft(2, '0')}-${controller.selectedDate.value!.day.toString().padLeft(2, '0')}',
                            icon: Icons.calendar_today,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2030),
                              );
                              if (date != null) controller.selectedDate.value = date;
                            },
                          )),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('시간'),
                      Obx(() => _buildPickerButton(
                            text: controller.selectedTime.value == null
                                ? '시간 선택'
                                : '${controller.selectedTime.value!.hour.toString().padLeft(2, '0')}:${controller.selectedTime.value!.minute.toString().padLeft(2, '0')}',
                            icon: Icons.access_time,
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) controller.selectedTime.value = time;
                            },
                          )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            _buildLabel('비밀번호 (4자리)'),
            _buildPasswordField(
              controller: controller.passwordController,
              hint: '숫자 4자리 입력',
              icon: Icons.lock_outline,
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            final ok = await controller.createMeetingRoom();
                            if (!ok) return;

                            Get.back();
                            Future.delayed(const Duration(milliseconds: 120), () {
                              if (Get.isSnackbarOpen == true) Get.closeAllSnackbars();
                              Get.snackbar(
                                '완료',
                                '모임이 생성되었습니다.',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            '모임 개설하기',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- UI Helpers ----------

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.notoSansKr(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: _kSub,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        obscureText: true,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPickerButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isHint = text.contains('선택');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.notoSansKr(
                color: isHint ? const Color(0xFF9CA3AF) : _kText,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _safeSnack(String title, String msg) {
    if (Get.isSnackbarOpen == true) Get.closeAllSnackbars();
    Get.snackbar(title, msg, snackPosition: SnackPosition.BOTTOM);
  }
}
