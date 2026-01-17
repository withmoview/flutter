// lib/models/meeting_room.dart

class MeetingRoom {
  final String? id; // 서버 int든 string이든 문자열로 통일
  final String hostId; // hostId/host_username 등 서버 필드 대응
  final String title;
  final String movieTitle;

  // TMDB 선택 필드
  final int? movieId;
  final String? moviePosterPath;

  final String theater;
  final DateTime meetingTime;

  // ⚠️ 보안상 서버에서 내려주면 안 되지만,
  // 기존 UI 구조 유지 위해 nullable로 둠 (목록에서는 안 쓰는 걸 권장)
  final String? password;

  final int maxMembers;
  final List<String> participantIds;
  final DateTime createdAt;

  MeetingRoom({
    this.id,
    required this.hostId,
    required this.title,
    required this.movieTitle,
    this.movieId,
    this.moviePosterPath,
    required this.theater,
    required this.meetingTime,
    this.password,
    this.maxMembers = 4,
    this.participantIds = const [],
    required this.createdAt,
  });

  // ✅ 서버 JSON -> 앱 모델 (snake/camel 혼합 대응)
  factory MeetingRoom.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'] ?? json['_id'];

    final host = _asString(
      json['hostId'] ??
          json['host_id'] ??
          json['hostUsername'] ??
          json['host_username'] ??
          json['host'] ??
          '',
    );

    final participantsRaw =
        json['participantIds'] ?? json['participant_ids'] ?? json['participants'] ?? const [];
    final participants = _asStringList(participantsRaw);

    final maxMembers = _asInt(json['maxMembers'] ?? json['max_members'] ?? 4, fallback: 4);

    final meetingTimeStr = json['meetingTime'] ?? json['meeting_time'];
    final meetingTime = _asDateTime(meetingTimeStr) ?? DateTime.now();

    final createdAtStr = json['createdAt'] ?? json['created_at'];
    final createdAt = _asDateTime(createdAtStr) ?? DateTime.now();

    final movieId = _asNullableInt(json['movieId'] ?? json['movie_id']);
    final posterPath = _asNullableString(json['moviePosterPath'] ?? json['movie_poster_path']);

    return MeetingRoom(
      id: idVal == null ? null : idVal.toString(),
      hostId: host,
      title: _asString(json['title']),
      movieTitle: _asString(json['movieTitle'] ?? json['movie_title']),
      movieId: movieId,
      moviePosterPath: posterPath,
      theater: _asString(json['theater']),
      meetingTime: meetingTime,
      password: _asNullableString(json['password']), // 서버가 안 주면 null
      maxMembers: maxMembers,
      participantIds: participants,
      createdAt: createdAt,
    );
  }

  // ✅ 앱 -> 서버 전송 (ApiService.createMeeting()랑 맞춰서 camelCase로 통일)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'movieTitle': movieTitle,
      'movieId': movieId,
      'moviePosterPath': moviePosterPath,
      'theater': theater,
      'meetingTime': meetingTime.toIso8601String(),
      'password': password,
      'maxMembers': maxMembers,
    };
  }

  String? get moviePosterUrl {
    final p = moviePosterPath;
    if (p == null || p.isEmpty) return null;
    return 'https://image.tmdb.org/t/p/w780$p';
  }

  // ---- helpers ----
  static String _asString(dynamic v) => (v ?? '').toString();

  static String? _asNullableString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    return int.tryParse((v ?? '').toString()) ?? fallback;
  }

  static int? _asNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static DateTime? _asDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  static List<String> _asStringList(dynamic v) {
    if (v == null) return <String>[];
    if (v is List) {
      return v.map((e) => e.toString()).toList();
    }
    final s = v.toString();
    if (s.contains(',')) {
      return s
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (s.trim().isEmpty) return <String>[];
    return <String>[s.trim()];
  }
}

extension MeetingRoomCopy on MeetingRoom {
  MeetingRoom copyWith({
    String? id,
    String? hostId,
    String? title,
    String? movieTitle,
    int? movieId,
    String? moviePosterPath,
    String? theater,
    DateTime? meetingTime,
    String? password,
    int? maxMembers,
    List<String>? participantIds,
    DateTime? createdAt,
  }) {
    return MeetingRoom(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      title: title ?? this.title,
      movieTitle: movieTitle ?? this.movieTitle,
      movieId: movieId ?? this.movieId,
      moviePosterPath: moviePosterPath ?? this.moviePosterPath,
      theater: theater ?? this.theater,
      meetingTime: meetingTime ?? this.meetingTime,
      password: password ?? this.password,
      maxMembers: maxMembers ?? this.maxMembers,
      participantIds: participantIds ?? this.participantIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
