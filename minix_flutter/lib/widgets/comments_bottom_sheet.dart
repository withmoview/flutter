import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../controllers/comment_controller.dart';
import '../services/mock_comment_service.dart';
import '../services/comment_service.dart';

/// ✅ 호출: openCommentsBottomSheet(context, tweetId);
Future<void> openCommentsBottomSheet(BuildContext context, int tweetId) async {
  // ✅ CommentService로 등록 (지금은 Mock 구현체)
  if (!Get.isRegistered<CommentService>()) {
    Get.put<CommentService>(MockCommentService(), permanent: true);
  }

  final tag = 'comments_$tweetId';

  // 같은 tweetId에 대한 컨트롤러가 이미 있으면 재사용, 없으면 생성
  if (!Get.isRegistered<CommentController>(tag: tag)) {
    Get.put(
      CommentController(
        tweetId: tweetId,
        service: Get.find<CommentService>(),
      ),
      tag: tag,
    );
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return _CommentsSheet(tweetId: tweetId, tag: tag);
    },
  );

  // 시트 닫힌 후 컨트롤러 정리(원하면 유지해도 됨)
  if (Get.isRegistered<CommentController>(tag: tag)) {
    Get.delete<CommentController>(tag: tag, force: true);
  }
}

class _CommentsSheet extends StatelessWidget {
  final int tweetId;
  final String tag;
  const _CommentsSheet({required this.tweetId, required this.tag});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CommentController>(tag: tag);

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 10,
          bottom: 10 + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들바
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EBF3),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 12),

            // 헤더
            Row(
              children: [
                const Text(
                  '댓글',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(width: 8),
                Obx(() => _CountChip(count: c.comments.length)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // 리스트 영역
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: Obx(() {
                if (c.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (c.comments.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 42, color: Colors.black26),
                          SizedBox(height: 10),
                          Text('첫 댓글을 남겨보세요', style: TextStyle(color: Colors.black45)),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: c.comments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final cm = c.comments[i];
                    return _CommentBubble(
                      name: cm.authorName,
                      username: cm.authorUsername,
                      timeText: timeago.format(cm.createdAt, locale: 'ko'),
                      content: cm.content,
                      isMine: cm.isMine,
                      onDelete: cm.isMine ? () => c.delete(cm.id) : null,
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 10),

            // 입력 바
            _InputBar(tag: tag),
          ],
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final int count;
  const _CountChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black54),
      ),
    );
  }
}

class _CommentBubble extends StatelessWidget {
  final String name;
  final String username;
  final String timeText;
  final String content;
  final bool isMine;
  final VoidCallback? onDelete;

  const _CommentBubble({
    required this.name,
    required this.username,
    required this.timeText,
    required this.content,
    required this.isMine,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isMine ? const Color(0xFFEFF2FF) : const Color(0xFFF7F8FC);
    final border = isMine ? const Color(0xFF4E73DF) : const Color(0xFFE8EBF3);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
              const SizedBox(width: 6),
              Text('@$username', style: const TextStyle(color: Colors.black45, fontSize: 12)),
              const SizedBox(width: 6),
              Text('· $timeText', style: const TextStyle(color: Colors.black38, fontSize: 12)),
              const Spacer(),
              if (onDelete != null)
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEEF0),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE84A5F).withOpacity(0.25)),
                    ),
                    child: const Text(
                      '삭제',
                      style: TextStyle(color: Color(0xFFE84A5F), fontSize: 12, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(height: 1.25)),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final String tag;
  const _InputBar({required this.tag});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CommentController>(tag: tag);
    final textCtrl = TextEditingController();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EBF3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textCtrl,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '댓글을 입력하세요',
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (v) => c.draft.value = v,
              onSubmitted: (_) async {
                await c.add();
                textCtrl.clear();
              },
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            final enabled = c.draft.value.trim().isNotEmpty;
            return InkWell(
              onTap: enabled
                  ? () async {
                      await c.add();
                      textCtrl.clear();
                    }
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: enabled ? const Color(0xFF7C6BFF) : const Color(0xFFE0E3EA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '전송',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
