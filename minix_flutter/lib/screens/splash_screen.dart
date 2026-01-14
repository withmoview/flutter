import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math; // 애니메이션 수학 계산용
import 'package:google_fonts/google_fonts.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // 디자인 통일 컬러
  final Color _primaryColor = const Color(0xFF4E73DF);


  @override
  void initState() {
    super.initState();
    // 애니메이션을 충분히 보여주기 위해 2초로 약간 늘림
    Future.delayed(const Duration(seconds: 2), () {
      Get.offNamed('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. 로고 (로그인 화면과 동일한 그림자 스타일 적용)
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/movie.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),

            // 2. 앱 이름
            Text(
              ' withmovie',
              style: GoogleFonts.dancingScript(
              color: const Color(0XFF4E73DF),
              fontWeight: FontWeight.w700,
              fontSize: 28,
            ),
            ),
            const SizedBox(height: 48),

            // 3. 커스텀 점 3개 애니메이션 (도로롱~)
            JumpingDots(color: _primaryColor),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// [커스텀 위젯] 점 3개가 웨이브 타는 애니메이션
// 외부 라이브러리 없이 구현함
// ---------------------------------------------------------
class JumpingDots extends StatefulWidget {
  final Color color;
  const JumpingDots({super.key, required this.color});

  @override
  State<JumpingDots> createState() => _JumpingDotsState();
}

class _JumpingDotsState extends State<JumpingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 1.2초 주기로 반복
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60, // 전체 너비
      height: 20, // 전체 높이
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) {
              // 각 점마다 시간차(phase)를 줘서 웨이브 효과를 만듦
              // sin 함수를 이용해 -1 ~ 1 사이를 오가게 함
              final double delay = index * 0.2;
              final double value = math.sin((_controller.value * 2 * math.pi) - delay);
              
              // 위로 튀어오르는 높이 계산 (0 ~ 10 픽셀)
              // value가 양수일 때만 튀어오르게 하여 바닥에 닿는 느낌 구현
              final double yOffset = value > 0 ? -value * 8 : 0; 
              
              // 점의 투명도 조절 (튀어오를 때 약간 연해짐)
              final double opacity = value > 0 ? 0.6 : 1.0;

              return Transform.translate(
                offset: Offset(0, yOffset),
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}