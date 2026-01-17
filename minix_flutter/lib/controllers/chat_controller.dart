import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/chat_message.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';

class ChatController extends GetxController {
  final String meetingId;
  ChatController({required this.meetingId});

  final ApiService _api = Get.find<ApiService>();
  final AuthController _auth = Get.find<AuthController>();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;

  final inputCtrl = TextEditingController();
  Timer? _timer;

  // ✅ 요청 겹침 방지
  bool _loadingNow = false;

  // ✅ 닫힌 뒤 setState/assign 방지
  bool _disposed = false;

  // ✅ 마지막으로 받아온 메시지 시각(있으면 중복 감소에 도움)
  DateTime? _lastServerTime;

  String get myUsername => (_auth.user.value?.username ?? '').trim();

  @override
  void onInit() {
    super.onInit();
    load();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => load(silent: true));
  }

  @override
  void onClose() {
    _disposed = true;
    _timer?.cancel();
    inputCtrl.dispose();
    super.onClose();
  }

  /// 서버 응답이
  /// - [ {...}, {...} ]
  /// - { "data": [ {...} ] }
  /// 두 형태 다 올 수 있게 안전 파서
  List<Map<String, dynamic>> _extractList(dynamic body) {
    if (body is List) {
      return body.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (body is Map) {
      final data = body['data'];
      if (data is List) {
        return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
    }
    return [];
  }

  /// createdAt/created_at/time 등 섞여도 최대한 읽기
  DateTime _readCreatedAt(Map<String, dynamic> json) {
    final v = (json['createdAt'] ?? json['created_at'] ?? json['time'] ?? '').toString();
    return DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<void> load({bool silent = false}) async {
    if (_disposed) return;
    if (_loadingNow) return; // ✅ 겹치기 방지
    _loadingNow = true;

    if (!silent) isLoading.value = true;

    try {
      final raw = await _api.getMeetingMessages(meetingId);

      if (_disposed) return;

      final listJson = _extractList(raw);

      // ✅ ChatMessage.fromJson이 Map을 받는다고 가정
      final next = listJson
          .map((m) => ChatMessage.fromJson(m, myUsername: myUsername))
          .toList();

      // 오래된 -> 최신
      next.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // ✅ 마지막 서버 시간 업데이트(있으면)
      if (listJson.isNotEmpty) {
        final lastTime = _readCreatedAt(listJson.last);
        if (lastTime.millisecondsSinceEpoch > 0) _lastServerTime = lastTime;
      }

      // ✅ 폴링이 덮어쓰기 때문에 화면이 튀는 걸 줄이기 위해:
      //    "서버가 준 리스트"를 기준으로 하되,
      //    방금 내가 send()에서 optimistic로 추가한 메시지가 아직 서버에 반영되기 전이면 유지
      final merged = _mergeKeepOptimistic(messages.toList(), next);

      messages.assignAll(merged);
    } catch (e) {
      if (!silent) {
        Get.snackbar('오류', '채팅을 불러올 수 없습니다.', snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      _loadingNow = false;
      if (!silent) isLoading.value = false;
    }
  }

  /// ✅ optimistic 메시지 유지(짧은 시간 동안만)
  /// - 서버 리스트(next)에 없는 "내가 보낸 메시지"가 기존(old)에 있으면 붙여줌
  /// - 단, 너무 오래된 optimistic는 제거
  List<ChatMessage> _mergeKeepOptimistic(List<ChatMessage> old, List<ChatMessage> next) {
    // 서버에서 받은 메시지 id 집합
    final serverIds = next.map((e) => e.id).toSet();

    // old 중에서 서버에 아직 없는 내 메시지(optimistic)만 골라서 유지
    final keep = <ChatMessage>[];

    final now = DateTime.now();
    for (final m in old) {
      if (serverIds.contains(m.id)) continue;
      if (!m.isMine) continue;

      // 20초 이상 지난 optimistic는 버림(서버에서 영영 안오면 중복 방지)
      if (now.difference(m.createdAt).inSeconds > 20) continue;

      keep.add(m);
    }

    final merged = [...next, ...keep];
    merged.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return merged;
  }

  Future<void> send() async {
    final text = inputCtrl.text.trim();
    if (text.isEmpty) return;

    inputCtrl.clear();

    // ✅ optimistic 메시지 즉시 추가 (id는 임시)
    final tempId = 'temp_${DateTime.now().microsecondsSinceEpoch}';
    final optimistic = ChatMessage(
      id: tempId,
      meetingId: meetingId,
      content: text,
      createdAt: DateTime.now(),
      authorName: _auth.user.value?.name ?? 'Me',
      authorUsername: myUsername.isEmpty ? 'me' : myUsername,
      isMine: true,
    );
    messages.add(optimistic);
    messages.refresh();

    try {
      final created = await _api.sendMeetingMessage(meetingId: meetingId, content: text);

      if (_disposed) return;

      if (created == null || created.isEmpty) {
        // 실패면 optimistic 제거
        messages.removeWhere((m) => m.id == tempId);
        Get.snackbar('오류', '메시지 전송 실패', snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // 서버 메시지로 교체(임시 id -> 서버 id)
      final serverMsg = ChatMessage.fromJson(created, myUsername: myUsername);

      final idx = messages.indexWhere((m) => m.id == tempId);
      if (idx != -1) {
        messages[idx] = serverMsg;
        messages.refresh();
      } else {
        // 혹시 없으면 그냥 add
        messages.add(serverMsg);
        messages.refresh();
      }

      // 다음 폴링 전에도 한 번 동기화(원하면 제거 가능)
      await load(silent: true);
    } catch (e) {
      // 실패면 optimistic 제거
      messages.removeWhere((m) => m.id == tempId);
      Get.snackbar('오류', '메시지 전송 실패', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
