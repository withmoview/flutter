// lib/screens/meeting_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/chat_controller.dart';
import '../models/meeting_room.dart';

class MeetingChatScreen extends StatelessWidget {
  const MeetingChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MeetingRoom room = Get.arguments as MeetingRoom;
    final meetingId = (room.id ?? '').trim();

    if (meetingId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('meetingId가 없습니다.')),
      );
    }

    final tag = 'chat_$meetingId';

    final c = Get.isRegistered<ChatController>(tag: tag)
        ? Get.find<ChatController>(tag: tag)
        : Get.put(ChatController(meetingId: meetingId), tag: tag);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(
          room.title,
          style: GoogleFonts.notoSansKr(
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (c.messages.isEmpty) {
                return const Center(child: Text('첫 메시지를 보내보세요'));
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                itemCount: c.messages.length,
                itemBuilder: (_, i) {
                  final m = c.messages[i];
                  final isMine = m.isMine;

                  return Align(
                    alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isMine ? const Color(0xFFEFF2FF) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black.withOpacity(0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (!isMine)
                            Text(
                              '@${m.authorUsername}', // ✅ 여기 수정
                              style: const TextStyle(fontSize: 11, color: Colors.black54),
                            ),
                          Text(m.content, style: const TextStyle(fontSize: 14, height: 1.25)),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: c.inputCtrl,
                      decoration: const InputDecoration(
                        hintText: '메시지 입력',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => c.send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: c.send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4E73DF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('전송', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
