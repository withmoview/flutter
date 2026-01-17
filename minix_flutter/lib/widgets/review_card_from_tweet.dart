import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/tweet.dart';

import 'package:minix_flutter/widgets/comments_bottom_sheet.dart';

class ReviewCardFromTweet extends StatelessWidget {
  final Tweet tweet;
  final VoidCallback onLike;
  final VoidCallback? onDelete;

  const ReviewCardFromTweet({
    super.key,
    required this.tweet,
    required this.onLike,
    this.onDelete,
  });

@override
Widget build(BuildContext context) {
  final parsed = _parse(tweet.content);

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F8FC),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 왼쪽 포스터(지금은 서버 저장이 없어서 기본 아이콘)
ClipRRect(
  borderRadius: BorderRadius.circular(14),
  child: Container(
    width: 64,
    height: 86,
    color: const Color(0xFFE6E9F2),
    child: (parsed.posterUrl.isNotEmpty)
        ? Image.network(
            parsed.posterUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.local_movies_outlined,
                color: Colors.white70, size: 30),
          )
        : const Icon(Icons.local_movies_outlined, color: Colors.white70, size: 30),
  ),
),

        const SizedBox(width: 12),

        // 가운데 텍스트 영역
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                parsed.title.isEmpty ? '(제목 없음)' : parsed.title,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // 별점 + 한줄평
              Text(
                '별점 ${parsed.rating.toStringAsFixed(1)} · 한줄평: ${_oneLine(parsed.text)}',
                style: const TextStyle(fontSize: 12.5, color: Colors.black54, height: 1.25),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 10),

              // 태그/칩
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  const _TagChip(text: '내 리뷰', bg: Color(0xFFEFF2FF), fg: Color(0xFF4E73DF)),
                  const _TagChip(text: '모임 리뷰', bg: Color(0xFFEFF2FF), fg: Color(0xFF4E73DF)),
                  _TagChip(
                    text: parsed.genre.isEmpty ? '장르' : parsed.genre,
                    bg: const Color(0xFFE7FBF5),
                    fg: const Color(0xFF1BAA79),
                  ),
                  InkWell(
                    onTap: onLike,
                    borderRadius: BorderRadius.circular(999),
                    child: _TagChip(
                      text: tweet.isLiked ? '♥ ${tweet.likeCount}' : '♡ ${tweet.likeCount}',
                      bg: const Color(0xFFFFEEF0),
                      fg: const Color(0xFFE84A5F),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // 오른쪽 버튼들 (댓글/공유/삭제)
        Column(
          children: [
            _SideButton(label: '댓글', onTap: () => openCommentsBottomSheet(context, tweet.id)),
            const SizedBox(height: 8),
            _SideButton(label: '공유', onTap: () {/* TODO */}),
            if (onDelete != null) ...[
              const SizedBox(height: 8),
              _SideButton(label: '삭제', danger: true, onTap: onDelete!),
            ],
          ],
        ),
      ],
    ),
  );
}


_ParsedReview _parse(String content) {
  if (!content.startsWith('[REVIEW]')) {
    return _ParsedReview(title: '', genre: '', rating: 0, text: content, posterUrl: '');
  }

  String title = '';
  String genre = '';
  double rating = 0;
  String text = '';
  String posterUrl = '';

  final lines = content.split('\n');

  // TEXT= 이후 줄바꿈 포함 대응
  bool inText = false;
  final textBuf = <String>[];

  for (final line in lines) {
    if (line.startsWith('TITLE=')) title = line.substring(6).trim();
    else if (line.startsWith('GENRE=')) genre = line.substring(6).trim();
    else if (line.startsWith('RATING=')) rating = double.tryParse(line.substring(7).trim()) ?? 0;
    else if (line.startsWith('POSTER=')) posterUrl = line.substring(7).trim();
    else if (line.startsWith('TEXT=')) {
      inText = true;
      textBuf.add(line.substring(5)); // TEXT= 뒤 내용
    } else if (inText) {
      textBuf.add(line); // TEXT 이후 줄들
    }
  }

  text = textBuf.join('\n').trim();

  return _ParsedReview(
    title: title,
    genre: genre,
    rating: rating,
    text: text,
    posterUrl: posterUrl,
  );
}

}

class _ParsedReview {
  final String title;
  final String genre;
  final double rating;
  final String text;
  final String posterUrl; // ✅ 추가
  _ParsedReview({required this.title, required this.genre, required this.rating, required this.text,required this.posterUrl});
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54)),
    );
  }
}

String _oneLine(String s) => s.replaceAll('\n', ' ').trim();

class _TagChip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _TagChip({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}

class _SideButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _SideButton({required this.label, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final bg = danger ? const Color(0xFFFFEEF0) : Colors.white;
    final fg = danger ? const Color(0xFFE84A5F) : const Color(0xFF4E73DF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 52,
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8EBF3)),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: fg)),
      ),
    );
  }
}
