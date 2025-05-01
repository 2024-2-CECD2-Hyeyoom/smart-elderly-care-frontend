import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screens/signUp_screen.dart';
import 'package:frontend/screens/login_screens/find_password_screen.dart';
import 'package:frontend/widgets/custom_popUp.dart';

enum LoginType { user, admin }

class LoginScreen extends StatelessWidget {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ValueNotifier<bool> autoLogin = ValueNotifier(false); // 자동 로그인 상태 관리

  final LoginType loginType;

  LoginScreen({super.key, required this.loginType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () {
          // 입력창 포커스 해제 → 키보드 닫힘
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    loginType == LoginType.user
                        ? '나의 생활 패턴 분석 서비스'
                        : '모니터링 케어 서비스',
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '로그인',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '아이디, 비밀번호를 입력해주세요',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 60),
                  TextField(
                    controller: idController,
                    decoration: const InputDecoration(
                      labelText: '아이디:',
                      hintText: '입력해주세요',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '비밀번호:',
                      hintText: '입력해주세요',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: autoLogin,
                        builder: (context, value, child) {
                          return Checkbox(
                            value: value,
                            onChanged: (newValue) {
                              autoLogin.value = newValue!;
                            },
                          );
                        },
                      ),
                      const Text('자동 로그인'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          if (loginType == LoginType.user) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FindPasswordScreen(
                                    loginType: LoginType.user),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const FindPasswordScreen(
                                        loginType: LoginType.admin,
                                      )),
                            );
                          }
                        },
                        child: const Text(
                          '비밀번호 찾기',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const Text('|'),
                      TextButton(
                        onPressed: () {
                          if (loginType == LoginType.user) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(
                                    loginType: LoginType.user),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignupScreen(
                                        loginType: LoginType.admin,
                                      )),
                            );
                          }
                        },
                        child: const Text(
                          '회원가입',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(160, 50),
                    ),
                    onPressed: () {
                      final id = idController.text.trim();
                      final pw = passwordController.text;

                      // 로그인 실패 조건 예시 (추후 서버 연동 시 수정)
                      if (id != "123" || pw != "123") {
                        // 로그인 실패 팝업
                        showDialog(
                          context: context,
                          builder: (_) => const CustomDialog(
                              content: '아이디 또는 비밀번호가 올바르지 않습니다.'),
                        );
                      }

                      // 로그인 성공 시 페이지 이동
                      // 예: Navigator.pushReplacement(...);
                    },
                    child: const Text(
                      '로그인',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
