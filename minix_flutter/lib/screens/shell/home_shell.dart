import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minix_flutter/screens/tabs/home_screen.dart';
import 'package:minix_flutter/screens/profile_screen.dart';
import 'package:minix_flutter/controllers/main_controller.dart'; // 1단계 파일 import

import '../../models/bottom_nav_item.dart';
import '../../widgets/bottom_bar.dart';

import '../tabs/meeting_tab.dart';
import '../tabs/community_tab.dart';

class HomeShell extends StatelessWidget { // StatefulWidget -> StatelessWidget으로 변경
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    // 🌟 여기서 컨트롤러를 등록(put)합니다.
    final controller = Get.put(MainController());

    final items = const [
      BottomNavItem(label: '홈', icon: Icons.home_rounded),
      BottomNavItem(label: '모임', icon: Icons.people_alt_rounded),
      BottomNavItem(label: '커뮤니티', icon: Icons.chat_bubble_outline_rounded),
      BottomNavItem(label: '마이', icon: Icons.person_rounded),
    ];

    final pages = const [
      HomeScreen(),
      MeetingTab(),
      CommunityTab(),
      ProfileScreen(),
    ];

    return Scaffold(
      // FAB 로직도 controller.selectedIndex를 관찰하도록 Obx 사용 가능 (생략 가능)
      floatingActionButton: null, 
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: Stack(
        children: [
          // 1) 본문 (탭 화면들)
          Positioned.fill(
            // 🌟 Obx로 감싸서 index가 바뀌면 화면이 다시 그려지게 함
            child: Obx(() => IndexedStack(
              index: controller.selectedIndex.value, 
              children: pages,
            )),
          ),

          // 2) BottomBar 오버레이
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Obx(() => BottomBar(
                items: items,
                index: controller.selectedIndex.value, // 🌟 컨트롤러 값 사용
                onChanged: (i) => controller.changeTabIndex(i), // 🌟 컨트롤러 함수 호출
                onAiTap: () => Get.toNamed('/ai'),
              )),
            ),
          ),
        ],
      ),
    );
  }
}