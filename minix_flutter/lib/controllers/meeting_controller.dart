// lib/controllers/meeting_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/meeting_room.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';

class MeetingController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  // 입력 컨트롤러
  final titleController = TextEditingController();
  final movieController = TextEditingController();
  final theaterController = TextEditingController();
  final passwordController = TextEditingController();

  // 선택 값
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);

  // TMDB 선택값
  final RxInt selectedMovieId = RxInt(-1);
  final RxString selectedMoviePosterPath = ''.obs;

  // 상태
  final isLoading = false.obs;

  // 서버에서 받아오는 모임 목록
  final RxList<MeetingRoom> meetings = <MeetingRoom>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMeetings();
  }

  @override
  void onClose() {
    titleController.dispose();
    movieController.dispose();
    theaterController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void setSelectedMovie({
    required int movieId,
    required String title,
    String? posterPath,
  }) {
    selectedMovieId.value = movieId;
    selectedMoviePosterPath.value = posterPath ?? '';
    movieController.text = title;
  }

  void clearSelectedMovie() {
    selectedMovieId.value = -1;
    selectedMoviePosterPath.value = '';
  }

  Future<void> loadMeetings() async {
    isLoading.value = true;
    try {
      final raw = await _api.getMeetings();
      final list = raw
          .whereType<Map>()
          .map((m) => MeetingRoom.fromJson(Map<String, dynamic>.from(m)))
          .toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      meetings.assignAll(list);
    } catch (_) {
      Get.snackbar('오류', '모임 목록을 불러올 수 없습니다');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createMeetingRoom() async {
    final title = titleController.text.trim();
    final movieTitle = movieController.text.trim();
    final theater = theaterController.text.trim();
    final pw = passwordController.text.trim();

    if (title.isEmpty ||
        movieTitle.isEmpty ||
        theater.isEmpty ||
        pw.isEmpty ||
        selectedDate.value == null ||
        selectedTime.value == null) {
      Get.snackbar('알림', '모든 정보를 입력해주세요.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (!RegExp(r'^\d{4}$').hasMatch(pw)) {
      Get.snackbar('알림', '비밀번호는 숫자 4자리여야 합니다.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    isLoading.value = true;
    try {
      final date = selectedDate.value!;
      final time = selectedTime.value!;
      final meetingTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);

      final int? movieId = (selectedMovieId.value >= 0) ? selectedMovieId.value : null;
      final String? posterPath =
          selectedMoviePosterPath.value.trim().isEmpty ? null : selectedMoviePosterPath.value.trim();

      final created = await _api.createMeeting(
        title: title,
        movieTitle: movieTitle,
        movieId: movieId,
        moviePosterPath: posterPath,
        theater: theater,
        meetingTime: meetingTime,
        password: pw,
        maxMembers: 4,
      );

      if (created == null || created.isEmpty) {
        Get.snackbar('오류', '모임 생성 실패');
        return false;
      }

      _clearFields();
      clearSelectedMovie();
      await loadMeetings();
      return true;
    } catch (_) {
      Get.snackbar('오류', '모임 생성 중 오류가 발생했습니다');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _clearFields() {
    titleController.clear();
    movieController.clear();
    theaterController.clear();
    passwordController.clear();
    selectedDate.value = null;
    selectedTime.value = null;
  }

  Future<MeetingRoom?> joinMeeting({
    required MeetingRoom room,
    required String password,
  }) async {
    final id = room.id?.toString();
    if (id == null || id.isEmpty) {
      Get.snackbar('오류', 'meeting id가 없습니다');
      return null;
    }

    try {
      final data = await _api.joinMeeting(meetingId: id, password: password.trim());
      if (data == null || data.isEmpty) {
        Get.snackbar('실패', '비밀번호가 올바르지 않거나 참가할 수 없습니다');
        return null;
      }

      final updated = MeetingRoom.fromJson(data);

      final idx = meetings.indexWhere((m) => m.id?.toString() == id);
      if (idx >= 0) {
        meetings[idx] = updated;
      } else {
        meetings.insert(0, updated);
      }
      meetings.refresh();

      return updated;
    } catch (_) {
      Get.snackbar('오류', '모임 참가 실패');
      return null;
    }
  }

  Future<bool> leaveMeeting({required MeetingRoom room}) async {
    final id = room.id?.toString();
    if (id == null || id.isEmpty) {
      Get.snackbar('오류', 'meeting id가 없습니다');
      return false;
    }

    try {
      final ok = await _api.leaveMeeting(meetingId: id);
      if (!ok) {
        Get.snackbar('실패', '모임 나가기에 실패했습니다');
        return false;
      }
      await loadMeetings();
      return true;
    } catch (_) {
      Get.snackbar('오류', '모임 나가기 실패');
      return false;
    }
  }

  Future<bool> deleteMeeting(String meetingId) async {
    try {
      final ok = await _api.deleteMeeting(meetingId);
      if (ok) {
        meetings.removeWhere((m) => m.id?.toString() == meetingId);
        meetings.refresh();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }

  String myUsernameOrAnon() {
    final auth = Get.find<AuthController>();
    final me = auth.user.value;
    final u = (me?.username ?? '').trim();
    return u.isEmpty ? '익명' : u;
  }

  bool isParticipant(MeetingRoom room) {
    final auth = Get.find<AuthController>();
    final me = auth.user.value;
    final myUsername = (me?.username ?? '').trim();
    if (myUsername.isEmpty) return false;
    return room.participantIds.map((e) => e.trim()).contains(myUsername);
  }
}
