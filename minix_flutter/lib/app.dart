import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart'; // 폰트 패키지 추가
import 'package:minix_flutter/screens/ai_screen.dart';
import 'package:minix_flutter/screens/shell/home_shell.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/tabs/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/compose_screen.dart';
import 'screens/meeting_chat_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mini X',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(name: '/home', page: () => const HomeShell()),
        GetPage(name: '/profile', page:() => const ProfileScreen()),
        GetPage(name: '/compose',  page: () => const ComposeScreen()),
        GetPage(name: '/ai', page: () => const AiScreen()),
        GetPage(name: '/meeting/chat', page: () => const MeetingChatScreen()),
      ],
    );
  }

  // 앱 테마 설정
  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,

      //배경색 (회색조) 적용
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),

      //메인 컬러 (Royal Blue)
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4E73DF),
      ),

      //앱바 스타일 (흰색 배경 + 검정 글씨)
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),

      //폰트 적용 (Noto Sans KR)
      textTheme: GoogleFonts.notoSansKrTextTheme(),
    );
  }
}