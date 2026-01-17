import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/tweet.dart';
import '../utils/review_format.dart';

class MyReviewTile extends StatelessWidget {
  final Tweet tweet;
  final VoidCallback onOpenComments;
  final VoidCallback onLike;
  final VoidCallback onDelete;

  const MyReviewTile({
    super.key,
    required this.tweet,
    required this.onOpenComments,
    required this.onLike,
    required this.onDelete,
  });

  static const _line = Color(0xFFE6E8EE);
  static const _muted = Color(0xFF6B7280);
  static const _text = Color(0xFF141A2A);
  static const _primary = Color(0xFF4E73DF);

  @override
  Widget build(BuildContext context) {
    final parsed = parseReview(tweet.content);
    final posterUrl = parsed.posterUrl.isEmpty ? null : parsed.posterUrl;
    final created = DateFormat('M/d HH:mm').format(tweet.createdAt);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 64,
              height: 86,
              color: const Color(0xFFF1F3F7),
              child: posterUrl == null
                  ? const Icon(Icons.local_movies_outlined, color: _muted)
                  : Image.network(
                      posterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image_outlined, color: _muted),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parsed.title.isEmpty ? '(제목 없음)' : parsed.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFC107)),
                    const SizedBox(width: 4),
                    Text(
                      parsed.rating.toStringAsFixed(1),
                      style: GoogleFonts.notoSansKr(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: _text,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      created,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  oneLine(parsed.text),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _muted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _MiniAction(
                      icon: tweet.isLiked ? Icons.favorite : Icons.favorite_border,
                      label: '${tweet.likeCount}',
                      color: tweet.isLiked ? const Color(0xFFE84A5F) : _muted,
                      onTap: onLike,
                    ),
                    const SizedBox(width: 10),
                    _MiniAction(
                      icon: Icons.mode_comment_outlined,
                      label: '댓글',
                      color: _primary,
                      onTap: onOpenComments,
                    ),
                    const Spacer(),
                    _MiniAction(
                      icon: Icons.delete_outline,
                      label: '삭제',
                      color: const Color(0xFFE84A5F),
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MiniAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  static const _line = Color(0xFFE6E8EE);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F7),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.notoSansKr(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
