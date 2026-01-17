import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minix_flutter/controllers/AiChatController.dart'; 
class AiScreen extends StatelessWidget {
  const AiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 컨트롤러 주입 (이미 main에서 했다면 Get.find, 아니면 Get.put)
    final controller = Get.find<AiChatController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('withmovie AI'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          // 1. 채팅 리스트 영역
          Expanded(
            child: Obx(() => ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final reversedIndex = controller.messages.length - 1 - index;
                final msg = controller.messages[reversedIndex];
                return _ChatBubble(message: msg);
              },
            )),
          ),
          
          // 2. 로딩 인디케이터
          Obx(() => controller.isLoading.value 
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("AI가 답변을 작성 중입니다...", style: TextStyle(color: Colors.grey)),
              ) 
            : const SizedBox.shrink()
          ),

          // 3. 입력창 영역
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 10,
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.textController,
                    decoration: InputDecoration(
                      hintText: '질문을 입력하세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0F2F5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => controller.sendMessage(), // 엔터키 처리
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0XFF4E73DF),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: controller.sendMessage,
                  ),
                ),
              ],
              
            ),
            
          ),
        ],
      ),
    );
  }
}

// 말풍선 위젯 (나/상대방 구분)
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isUser;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0XFF4E73DF) : const Color(0xFFE9EEF5),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(2),
            bottomRight: isMe ? const Radius.circular(2) : const Radius.circular(16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}