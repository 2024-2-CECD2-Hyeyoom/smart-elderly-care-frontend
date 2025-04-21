import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screens/login_screen.dart';

class FindPasswordScreen extends StatefulWidget {
  final LoginType loginType;
  const FindPasswordScreen({super.key, required this.loginType});

  @override
  State<FindPasswordScreen> createState() => _FindPasswordScreenState();
}

class _FindPasswordScreenState extends State<FindPasswordScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.black,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          '비밀번호 찾기',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // 키보드 닫기
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        widget.loginType == LoginType.user
                            ? '나의 생활 패턴 분석 서비스'
                            : '모니터링 케어 서비스',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w400),
                      ),
                      const Text('가입 시 입력한 정보를 입력해주세요',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // 아이디 입력
                const Text('아이디'),
                const SizedBox(height: 6),
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(
                    hintText: '아이디를 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // 이름 입력
                const Text('이름'),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: '이름을 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // 전화번호 입력
                const Text('전화번호'),
                const SizedBox(height: 6),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '전화번호를 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 50),

                // 비밀번호 찾기 버튼
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(180, 48),
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      // 🔐 비밀번호 찾기 로직 (서버 요청 등)
                      /*ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('비밀번호 찾기 요청 전송됨')),
                      );*/
                    },
                    child: const Text(
                      '비밀번호 찾기',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
