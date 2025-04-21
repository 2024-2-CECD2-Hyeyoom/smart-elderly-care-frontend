import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screens/login_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 144, 221, 252),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: Center(
          child: Column(
            children: [
              const Text(
                '서비스 유형을 선택해주세요',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 50,
              ),
              ChooseUserType(
                text: '나의 생활 패턴 보기',
                icon: Icons.bar_chart_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LoginScreen(loginType: LoginType.user),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),

              // 🔹 관리자 로그인
              ChooseUserType(
                text: '모니터링 서비스 이용하기',
                icon: Icons.admin_panel_settings_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LoginScreen(loginType: LoginType.admin),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

//사용자 선택 버튼 위젯
class ChooseUserType extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const ChooseUserType({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        width: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(
            Radius.circular(50),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 3,
              offset: const Offset(0, 3),
              color: const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.7),
            )
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Icon(
                icon,
                size: 50,
                color: const Color.fromARGB(255, 32, 53, 128),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
