// lib/models/meeting_room.dart

class MeetingRoom {
  final String? id; // 방 고유 ID (DB에서 생성)
  final String hostId; // 방장 UID (로그인한 유저)
  final String title; // 방 제목 (예: "오늘 밤 듄2 보실 분")
  final String movieTitle; // 영화 제목
  final String theater; // 영화관 (예: CGV 용산)
  final DateTime meetingTime; // 모임 날짜 및 시간
  final String password; // 입장 비밀번호 (4자리)
  final int maxMembers; // 최대 인원 (기본 4명 등)
  final List<String> participantIds; // 참여자 ID 목록
  final DateTime createdAt; // 방 생성 시간

  MeetingRoom({
    this.id,
    required this.hostId,
    required this.title,
    required this.movieTitle,
    required this.theater,
    required this.meetingTime,
    required this.password,
    this.maxMembers = 4, // 기본값 4명
    this.participantIds = const [],
    required this.createdAt,
  });

  // DB(JSON) 데이터를 앱에서 쓸 수 있게 변환
  factory MeetingRoom.fromJson(Map<String, dynamic> json, String id) {
    return MeetingRoom(
      id: id,
      hostId: json['hostId'] ?? '',
      title: json['title'] ?? '',
      movieTitle: json['movieTitle'] ?? '',
      theater: json['theater'] ?? '',
      meetingTime: DateTime.parse(json['meetingTime']), 
      password: json['password'] ?? '',
      maxMembers: json['maxMembers'] ?? 4,
      participantIds: List<String>.from(json['participantIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // 앱 데이터를 DB(JSON)로 보낼 때 변환
  Map<String, dynamic> toJson() {
    return {
      'hostId': hostId,
      'title': title,
      'movieTitle': movieTitle,
      'theater': theater,
      'meetingTime': meetingTime.toIso8601String(),
      'password': password,
      'maxMembers': maxMembers,
      'participantIds': participantIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}