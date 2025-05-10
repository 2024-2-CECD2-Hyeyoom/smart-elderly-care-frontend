import 'package:flutter/material.dart';

// 상단바 하단바 레이아웃 위젯

class CustomLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final int currentIndex;
  final Function(int) onTap;
  final bool showLogoutButton;

  const CustomLayout({
    super.key,
    required this.title,
    required this.body,
    required this.currentIndex,
    required this.onTap,
    this.showLogoutButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.black,
        elevation: 1,
        centerTitle: true,
        title: Text(title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            )),
        actions: [
          if (showLogoutButton)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton(
                onPressed: () {
                  // TODO: 로그아웃 로직
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 48, 81, 120),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(50, 40), // 크기 조절
                ),
                child: const Text(
                  "로그아웃",
                  style: TextStyle(
                    color: Color.fromARGB(255, 48, 81, 120),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black.withValues(alpha: 0.5),
        backgroundColor: const Color.fromARGB(255, 48, 81, 120),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.pan_tool_alt), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
