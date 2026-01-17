import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/meeting_room.dart';
import 'auth_controller.dart'; // ✅ 1. AuthController 임포트

class MeetingController extends GetxController {
  // 1. 입력창(TextField) 컨트롤러들
  final titleController = TextEditingController(); // 방 제목
  final movieController = TextEditingController(); // 영화 제목
  final theaterController = TextEditingController(); // 영화관
  final passwordController = TextEditingController(); // 비밀번호

  // 2. 날짜와 시간 선택 변수 (Obs)
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null); 
  Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);

  // 로딩 상태 및 데이터 리스트
  var isLoading = false.obs;
  
  // ✅ 생성된 모임들을 저장할 리스트 (메모리 저장소)
  RxList<MeetingRoom> meetings = <MeetingRoom>[].obs;

  // 3. 방 생성하기
  Future<void> createMeetingRoom() async {
    // (1) 유효성 검사
    if (titleController.text.isEmpty ||
        movieController.text.isEmpty ||
        theaterController.text.isEmpty ||
        passwordController.text.isEmpty ||
        selectedDate.value == null ||
        selectedTime.value == null) {
      Get.snackbar(
        "알림", "모든 정보를 입력해주세요!", 
        snackPosition: SnackPosition.BOTTOM, 
        backgroundColor: Colors.orange, 
        colorText: Colors.white
      );
      return;
    }

    isLoading.value = true;

    try {
      // (2) 날짜와 시간 합치기
      final date = selectedDate.value!;
      final time = selectedTime.value!;
      final finalDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);

      // ✅ [수정 핵심] AuthController에서 현재 로그인한 유저 정보 가져오기
      final authController = Get.find<AuthController>();
      final myInfo = authController.user.value;
      
      // 내 닉네임 가져오기 (없으면 '익명' 처리)
      final String myName = myInfo?.username ?? '익명';

      // (3) 모델 생성 (실제 내 이름 적용)
      final newRoom = MeetingRoom(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // 고유 ID 생성
        hostId: myName, // ✅ "host_user_123" 대신 실제 내 이름 사용
        title: titleController.text,
        movieTitle: movieController.text,
        theater: theaterController.text,
        meetingTime: finalDateTime,
        password: passwordController.text,
        participantIds: [myName], // ✅ 참여자 목록에도 나(방장) 추가
        createdAt: DateTime.now(),
        maxMembers: 4, // (기본값 설정, 필요시 입력받게 수정 가능)
      );

      // (4) 리스트에 추가 (맨 앞에 추가하여 최신순 유지)
      meetings.insert(0, newRoom); 

      // (5) 성공 처리
      Get.snackbar("성공", "모임이 생성되었습니다!");
      _clearFields(); // 입력창 초기화
      Get.back(); // 목록 화면으로 돌아가기

    } catch (e) {
      print("에러 발생: $e");
      Get.snackbar("오류", "방 생성 중 문제가 발생했습니다.");
    } finally {
      isLoading.value = false;
    }
  }

  // 입력창 초기화
  void _clearFields() {
    titleController.clear();
    movieController.clear();
    theaterController.clear();
    passwordController.clear();
    selectedDate.value = null;
    selectedTime.value = null;
  }
  
  @override
  void onClose() {
    titleController.dispose();
    movieController.dispose();
    theaterController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  bool checkPassword(MeetingRoom room, String inputPassword) {
    if (room.password == inputPassword) {
      return true; // 통과
    } else {
      Get.snackbar(
        "입장 실패", 
        "비밀번호가 일치하지 않습니다.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false; // 실패
    }
  }
  
  void deleteMeeting(String roomId) {
    // 리스트에서 해당 ID를 가진 방을 찾아서 제거 (RxList라 자동 갱신됨)
    meetings.removeWhere((room) => room.id == roomId);
    
    // 뒤로 가기 (목록 화면으로 이동)
    Get.back(); 
    
    Get.snackbar(
      "삭제 완료", "모임이 삭제되었습니다.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}