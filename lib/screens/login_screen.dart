import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_primary_button.dart';
import 'main_navigation_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    if (isLoading) {
      return;
    }

    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이메일과 비밀번호를 입력해주세요.')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final AppUser user = await ApiService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainNavigationScreen(loginUser: user),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('로그인 실패: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> moveToSignup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );

    if (result == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('회원가입이 완료되었습니다. 로그인해주세요.')));
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 38),
          SizedBox(height: 18),
          Text(
            '함께하는 여행',
            style: TextStyle(
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.8,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '로그인하고 여행방과 일정을 관리해보세요.',
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          buildInputField(
            controller: emailController,
            label: '이메일',
            icon: Icons.email_rounded,
          ),
          buildInputField(
            controller: passwordController,
            label: '비밀번호',
            icon: Icons.lock_rounded,
            obscureText: true,
          ),
          const SizedBox(height: 8),
          AppPrimaryButton(
            text: isLoading ? '로그인 중...' : '로그인',
            icon: Icons.login_rounded,
            onPressed: login,
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: moveToSignup,
            child: const Text(
              '계정이 없나요? 회원가입',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 36, 20, 28),
          child: Column(
            children: [
              buildHeader(),
              const SizedBox(height: 22),
              buildLoginCard(),
            ],
          ),
        ),
      ),
    );
  }
}
