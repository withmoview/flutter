import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minix_flutter/controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authController = Get.find<AuthController>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();

  // 디자인 통일을 위한 컬러 팔레트
  final Color _primaryColor = const Color(0xFF4E73DF);
  final Color _backgroundColor = Colors.white;
  final Color _inputFillColor = const Color(0xFFF2F4F8);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // 키보드 내리기
    FocusScope.of(context).unfocus();

    // 간단한 유효성 검사 (빈칸 체크)
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty) {
      Get.snackbar(
        '입력 오류',
        '모든 정보를 입력해주세요.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    final success = await _authController.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
    );

    if (success) {
      Get.offAllNamed('/home');
    } else {
      Get.snackbar(
        '회원가입 실패',
        _authController.error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  // 로그인 화면과 동일한 스타일의 Input Decoration
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey[500], size: 22),
      filled: true,
      fillColor: _inputFillColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _primaryColor, width: 1.5),
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
      // AppBar를 투명하게 만들어 개방감 확보
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              // 헤더 텍스트
              const Text(
                '회원가입',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '새로운 계정을 만들어보세요.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 32),

              // 1. 이름 입력
              TextField(
                controller: _nameController,
                decoration: _inputDecoration('이름 (실명)', Icons.badge_outlined),
              ),
              const SizedBox(height: 16),

              // 2. 사용자명 입력
              TextField(
                controller: _usernameController,
                decoration: _inputDecoration('사용자명 (ID)', Icons.account_circle_outlined),
              ),
              const SizedBox(height: 16),

              // 3. 이메일 입력
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('이메일', Icons.email_outlined),
              ),
              const SizedBox(height: 16),

              // 4. 비밀번호 입력
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: _inputDecoration('비밀번호', Icons.lock_outline),
                onSubmitted: (_) => _register(),
              ),
              const SizedBox(height: 32),

              // 5. 회원가입 버튼
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('회원가입 완료'),
                ),
              ),
              const SizedBox(height: 24),

              // 6. 로그인 링크
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '이미 계정이 있으신가요?',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: _primaryColor,
                    ),
                    child: const Text(
                      '로그인',
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
    );
  }
}