import 'package:get/get.dart';

class MainController extends GetxController {
  // 현재 선택된 탭 번호 (0: 홈, 1: 모임, 2: 커뮤니티, 3: 마이)
  RxInt selectedIndex = 0.obs;

  // 탭 바꾸는 함수
  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }
}