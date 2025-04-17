import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 144, 221, 252),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Center(
          child: Column(
            children: [
              Text(
                '사용자 유형을 선택해주세요',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 50,
              ),
              ChooseUserType(
                text: '나의 생활 패턴 보기',
                icon: Icons.bar_chart_outlined,
              ),
              SizedBox(
                height: 30,
              ),
              ChooseUserType(
                text: '모니터링 서비스 이용하기',
                icon: Icons.admin_panel_settings_rounded,
              ),
              SizedBox(
                height: 30,
              ),
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

  const ChooseUserType({
    super.key,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('버튼 누름');
      },
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
