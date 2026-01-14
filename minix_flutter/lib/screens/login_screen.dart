import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minix_flutter/controllers/auth_controller.dart';
// import 'register_screen.dart'; // 라우팅을 사용하므로 주석 처리하거나 필요시 사용
// import 'tabs/home_screen.dart'; // 위와 동일

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authController = Get.find<AuthController>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 최신 앱에서 많이 쓰는 브랜드 컬러 정의
  final Color _primaryColor = const Color(0xFF4E73DF); // 세련된 로얄 블루
  final Color _backgroundColor = Colors.white;
  final Color _inputFillColor = const Color(0xFFF2F4F8); // 아주 연한 회색

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // 키보드 내리기
    FocusScope.of(context).unfocus();

    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      Get.snackbar(
        '입력 오류',
        '이메일과 비밀번호를 모두 입력해주세요.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    final success = await _authController.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success) {
      Get.offAllNamed('/home');
    } else {
      Get.snackbar(
        '로그인 실패',
        _authController.error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  void _goToRegister() {
    Get.toNamed('/register');
  }

  // 입력 필드 스타일 통일함수
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey[500], size: 22),
      filled: true,
      fillColor: _inputFillColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), // 둥근 모서리
        borderSide: BorderSide.none, // 테두리 없음 (깔끔함)
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _primaryColor, width: 1.5), // 포커스시 색상
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // 스크롤 가능하게 하여 작은 화면 대응
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // 1. 로고 영역
                // 그림자 효과를 주어 앱 아이콘처럼 보이게 함
                Center(
                  child: Container(
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
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // 2. 타이틀 영역
                const Text(
                  '영화랑',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '다시 오신 것을 환영합니다!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 48),

                // 3. 입력 필드 영역
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  decoration: _inputDecoration('Email', Icons.email_outlined),
                ),
                const SizedBox(height: 20),
                
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  decoration: _inputDecoration('Password', Icons.lock_outline),
                  onSubmitted: (_) => _login(),
                ),
                
                const SizedBox(height: 24),

                // 4. 로그인 버튼
                SizedBox(
                  height: 56, // 요즘 앱들은 버튼이 높습니다
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0, // 그림자 제거 (Flat 디자인)
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('로그인'),
                  ),
                ),
                const SizedBox(height: 32),

                // 5. 회원가입 링크
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '계정이 없으신가요?',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    TextButton(
                      onPressed: _goToRegister,
                      style: TextButton.styleFrom(
                        foregroundColor: _primaryColor,
                      ),
                      child: const Text(
                        '회원가입',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}