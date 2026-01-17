import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/meeting_controller.dart';

class CreateMeetingScreen extends StatelessWidget {
  const CreateMeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 컨트롤러 주입 (화면이 생성될 때 로직도 같이 준비됨)
    final controller = Get.put(MeetingController());
    
    // 테마 컬러
    const primaryColor = Color(0XFF4E73DF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '모임 만들기',
          style: GoogleFonts.notoSansKr(
            fontWeight: FontWeight.w700, 
            color: Colors.black87
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('모임 제목'),
            _buildTextField(
              controller.titleController, 
              '예: 이번 주말 듄2 보러 가실 분',
              icon: Icons.campaign_outlined
            ),
            const SizedBox(height: 24),

            _buildLabel('영화 제목'),
            _buildTextField(
              controller.movieController, 
              '볼 영화 제목을 입력하세요',
              icon: Icons.movie_outlined
            ),
            const SizedBox(height: 24),

            _buildLabel('상영관 / 장소'),
            _buildTextField(
              controller.theaterController, 
              '예: CGV 용산아이파크몰',
              icon: Icons.location_on_outlined
            ),
            const SizedBox(height: 24),

            // 날짜 및 시간 선택 (터치 시 피커 띄움)
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
                            : '${controller.selectedDate.value!.year}-${controller.selectedDate.value!.month}-${controller.selectedDate.value!.day}',
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('시간'),
                      Obx(() => _buildPickerButton(
                        text: controller.selectedTime.value == null 
                            ? '시간 선택' 
                            : '${controller.selectedTime.value!.hour}:${controller.selectedTime.value!.minute.toString().padLeft(2, '0')}',
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
            const SizedBox(height: 24),

            _buildLabel('비밀번호 (4자리)'),
            _buildTextField(
              controller.passwordController, 
              '숫자 4자리 입력',
              isNumber: true,
              icon: Icons.lock_outline,
            ),
            
            const SizedBox(height: 40),

            // 생성 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value 
                    ? null 
                    : controller.createMeetingRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        '모임 개설하기',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
              )),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 라벨 위젯 (제목용)
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.notoSansKr(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  // 입력창 위젯
  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        obscureText: isNumber, // 비밀번호면 가리기
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // 선택 버튼 위젯 (날짜/시간용)
  Widget _buildPickerButton({required String text, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[500], size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: text.contains('선택') ? Colors.grey[400] : Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}