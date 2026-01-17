import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../controllers/auth_controller.dart';
import '../controllers/meeting_controller.dart';
import '../controllers/TweetController.dart';
import '../models/meeting_room.dart';
import '../models/tweet.dart';
import '../screens/webview_screen.dart';
import '../services/api_service.dart';
import '../screens/meeting_detail_screen.dart';
import '../widgets/comments_bottom_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authController = Get.find<AuthController>();
  final _api = Get.find<ApiService>();

  late final MeetingController _meetingController;
  late final TweetController _tweetController;

  // ✅ Home/Meeting/Community와 동일 토큰으로 통일
  static const _bg = Color(0xFFF4F6F8);
  static const _card = Colors.white;
  static const _line = Color(0xFFE6E8EE);
  static const _text = Color(0xFF141A2A);
  static const _muted = Color(0xFF6B7280);
  static const _primary = Color(0xFF4E73DF);

  @override
  void initState() {
    super.initState();

    _meetingController = Get.isRegistered<MeetingController>()
        ? Get.find<MeetingController>()
        : Get.put(MeetingController(), permanent: true);

    _tweetController = Get.isRegistered<TweetController>()
        ? Get.find<TweetController>()
        : Get.put(TweetController(), permanent: true);
  }

  Future<void> _changeProfileImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
    );
    if (image == null) return;

    try {
      final fileId = await _api.uploadImage(image);
      if (fileId == null) {
        Get.snackbar('오류', '이미지 업로드에 실패했습니다');
        return;
      }

      final success = await _api.updateProfile(profileImageId: fileId);
      if (success != null) {
        Get.snackbar('완료', '프로필 이미지가 변경되었습니다');
        await _authController.loadProfile();
      }
    } catch (_) {
      Get.snackbar('오류', '프로필 수정에 실패했습니다');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final user = _authController.user.value;
          if (user == null) return const SizedBox();

          final myUsername = user.username;

          final joinedRooms = _meetingController.meetings
              .where((r) => r.participantIds.contains(myUsername))
              .toList()
            ..sort((a, b) => a.meetingTime.compareTo(b.meetingTime));

          final myReviews = _tweetController.tweets
              .where((t) => t.username == myUsername && t.content.startsWith('[REVIEW]'))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ 헤더: MeetingTab과 동일 스타일
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
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: _primary,
                            ),
                          ),
                          Text(
                            'withmovie',
                            style: GoogleFonts.poppins(
                              color: _text,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    _CircleIconButton(
                      icon: Icons.description_outlined,
                      onTap: () {
                        Get.to(() => const WebViewScreen(
                              title: '이용약관',
                              url: 'https://banawy.store',
                            ));
                      },
                    ),
                    const SizedBox(width: 10),
                    _CircleIconButton(
                      icon: Icons.logout,
                      iconColor: Colors.redAccent,
                      onTap: () => _authController.logout(),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Profile card (flat)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _line),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _line, width: 1),
                            ),
                            child: CircleAvatar(
                              radius: 36,
                              backgroundImage: user.profile_image_id != null
                                  ? NetworkImage(_api.getImageUrl(user.profile_image_id!))
                                  : null,
                              backgroundColor: _primary,
                              child: user.profile_image_id == null
                                  ? Text(
                                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: InkWell(
                              onTap: _changeProfileImage,
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _card,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: _line),
                                ),
                                child: const Icon(Icons.camera_alt, size: 16, color: _muted),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: GoogleFonts.notoSansKr(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: _text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@${user.username}',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _muted,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _StatPill(label: '참가 모임', value: '${joinedRooms.length}'),
                                const SizedBox(width: 8),
                                _StatPill(label: '내 리뷰', value: '${myReviews.length}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // My Reviews
                _SectionHeader(
                  title: '내 리뷰',
                  subtitle: '커뮤니티에 작성한 리뷰',
                  trailing: null,
                ),
                const SizedBox(height: 10),

                if (myReviews.isEmpty)
                  _EmptyFlatCard(
                    icon: Icons.rate_review_outlined,
                    title: '아직 작성한 리뷰가 없어요',
                    desc: '커뮤니티 탭에서 리뷰를 작성해보세요.',
                  )
                else
                  Column(
                    children: List.generate(
                      myReviews.length > 3 ? 3 : myReviews.length,
                      (i) => Padding(
                        padding: EdgeInsets.only(bottom: i == 2 ? 0 : 10),
                        child: _MyReviewTile(
                          tweet: myReviews[i],
                          onOpenComments: () => openCommentsBottomSheet(context, myReviews[i].id),
                          onLike: () => _tweetController.toggleLike(myReviews[i].id),
                          onDelete: () => _tweetController.deleteTweet(myReviews[i].id),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 18),

                // Joined meetings
                _SectionHeader(
                  title: '참가한 모임',
                  subtitle: '모임을 눌러 상세로 이동',
                  trailing: null,
                ),
                const SizedBox(height: 10),

                if (joinedRooms.isEmpty)
                  _EmptyFlatCard(
                    icon: Icons.event_busy_outlined,
                    title: '참가한 모임이 없습니다',
                    desc: '모임 탭에서 새로운 모임에 참여해보세요.',
                  )
                else
                  Column(
                    children: List.generate(joinedRooms.length, (index) {
                      final room = joinedRooms[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: index == joinedRooms.length - 1 ? 0 : 10),
                        child: _JoinedMeetingFlatCard(
                          room: room,
                          onTap: () => Get.to(() => const MeetingDetailScreen(), arguments: room),
                        ),
                      );
                    }),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/* =========================
 *  Shared UI Pieces (원본 그대로)
 * ========================= */

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  static const _line = Color(0xFFE6E8EE);

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
            border: Border.all(color: _line),
          ),
          child: Icon(icon, color: iconColor ?? const Color(0xFF141A2A)),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.trailing,
  });

  static const _text = Color(0xFF141A2A);
  static const _muted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              title,
              style: GoogleFonts.notoSansKr(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: _text,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: GoogleFonts.notoSansKr(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: _muted,
                ),
              ),
            ],
          ]),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _EmptyFlatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _EmptyFlatCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  static const _line = Color(0xFFE6E8EE);
  static const _muted = Color(0xFF6B7280);
  static const _text = Color(0xFF141A2A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _line),
            ),
            child: Icon(icon, color: _muted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                title,
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: _text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: GoogleFonts.notoSansKr(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: _muted,
                  height: 1.35,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;

  const _StatPill({required this.label, required this.value});

  static const _line = Color(0xFFE6E8EE);
  static const _muted = Color(0xFF6B7280);
  static const _text = Color(0xFF141A2A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.notoSansKr(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: _muted,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: GoogleFonts.notoSansKr(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: _text,
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================
 *  Joined meeting card / My review tile는 사용자가 주신 원본 그대로 유지
 *  (아래는 그대로 붙여두시면 됩니다)
 * ========================= */

class _JoinedMeetingFlatCard extends StatelessWidget {
  final MeetingRoom room;
  final VoidCallback onTap;

  const _JoinedMeetingFlatCard({
    required this.room,
    required this.onTap,
  });

  static const _line = Color(0xFFE6E8EE);
  static const _muted = Color(0xFF6B7280);
  static const _text = Color(0xFF141A2A);
  static const _primary = Color(0xFF4E73DF);

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('M월 d일 (E) HH:mm', 'ko_KR').format(room.meetingTime);
    final isUpcoming = room.meetingTime.isAfter(DateTime.now());

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isUpcoming ? _primary : const Color(0xFF9CA3AF)).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _line),
                  ),
                  child: Text(
                    isUpcoming ? '예정' : '지난 모임',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isUpcoming ? _primary : const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Text(
                  dateStr,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              room.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.notoSansKr(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: _text,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.movie_outlined, size: 16, color: _muted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    room.movieTitle,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: _muted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    room.theater,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.people_outline, size: 16, color: _muted),
                const SizedBox(width: 6),
                Text(
                  '${room.participantIds.length}/${room.maxMembers}명',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MyReviewTile extends StatelessWidget {
  final Tweet tweet;
  final VoidCallback onOpenComments;
  final VoidCallback onLike;
  final VoidCallback onDelete;

  const _MyReviewTile({
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
    final parsed = _parseReview(tweet.content);
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
                  _oneLine(parsed.text),
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

/* ===== REVIEW parser ===== */

_ParsedReview _parseReview(String content) {
  if (!content.startsWith('[REVIEW]')) {
    return _ParsedReview(title: '', genre: '', rating: 0, text: content, posterUrl: '');
  }

  String title = '';
  String genre = '';
  double rating = 0;
  String text = '';
  String posterUrl = '';

  final lines = content.split('\n');

  bool inText = false;
  final textBuf = <String>[];

  for (final line in lines) {
    if (line.startsWith('TITLE=')) title = line.substring(6).trim();
    else if (line.startsWith('GENRE=')) genre = line.substring(6).trim();
    else if (line.startsWith('RATING=')) rating = double.tryParse(line.substring(7).trim()) ?? 0;
    else if (line.startsWith('POSTER=')) posterUrl = line.substring(7).trim();
    else if (line.startsWith('TEXT=')) {
      inText = true;
      textBuf.add(line.substring(5));
    } else if (inText) {
      textBuf.add(line);
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

class _ParsedReview {
  final String title;
  final String genre;
  final double rating;
  final String text;
  final String posterUrl;

  _ParsedReview({
    required this.title,
    required this.genre,
    required this.rating,
    required this.text,
    required this.posterUrl,
  });
}

String _oneLine(String s) => s.replaceAll('\n', ' ').trim();
