import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minix_flutter/screens/tabs/home_screen.dart';
import 'package:minix_flutter/screens/profile_screen.dart';

import '../../models/bottom_nav_item.dart';
import '../../widgets/bottom_bar.dart';

import '../tabs/meeting_tab.dart';
import '../tabs/community_tab.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _items = const [
    BottomNavItem(label: '홈', icon: Icons.home_rounded),
    BottomNavItem(label: '모임', icon: Icons.people_alt_rounded),
    BottomNavItem(label: '커뮤니티', icon: Icons.chat_bubble_outline_rounded),
    BottomNavItem(label: '마이', icon: Icons.person_rounded),
  ];

  final _pages = const [
    HomeScreen(),
    MeetingTab(),
    CommunityTab(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ bottomNavigationBar 쓰지 말고, body 위에 오버레이로 올립니다.
      body: Stack(
        children: [
          // 1) 본문(탭 화면들)
          Positioned.fill(
            child: IndexedStack(index: _index, children: _pages),
          ),

          // 2) BottomBar 오버레이
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: BottomBar(
                items: _items,
                index: _index,
                onChanged: (i) => setState(() => _index = i),
                onAiTap: () => Get.toNamed('/compose'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
