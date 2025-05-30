// lib/screens/login_screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screens/find_password_screen.dart';
import 'package:frontend/screens/login_screens/sign_up_screen.dart';
import 'package:frontend/widgets/custom_pop_up.dart';
import 'package:frontend/widgets/custom_snackbar.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/secure_storage_service.dart';
import 'package:frontend/models/login_request.dart';
import 'package:frontend/models/login_response.dart';
// 홈스크린을 별칭으로 import
import 'package:frontend/screens/service_for_me/home_screen.dart' as me;
import 'package:frontend/screens/service_for_carer/home_screen.dart' as carer;
import 'package:frontend/screens/service_for_center/home_screen.dart' as center;

enum LoginType { user, admin }

class LoginScreen extends StatefulWidget {
  final LoginType loginType;
  const LoginScreen({super.key, required this.loginType});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _autoLogin = ValueNotifier<bool>(false);

  bool _isLoading = false;

  Future<void> _onLoginPressed() async {
    setState(() => _isLoading = true);

    final phone = _idController.text.trim();
    final password = _pwController.text;
    if (phone.isEmpty || password.isEmpty) {
      showMessageBanner(context, '아이디와 비밀번호를 모두 입력해주세요.');
      setState(() => _isLoading = false);
      return;
    }

    try {
      final req = LoginRequest(phone: phone, password: password);
      final LoginResponse resp = await AuthService.instance.login(req);

      if (!mounted) return;
      if (resp.isSuccess && resp.result != null) {
        // 1) 토큰 저장
        await SecureStorageService.writeToken(resp.result!.token);

        // 2) role 에 따라 홈 화면으로 분기 이동
        switch (resp.result!.role) {
          case 'user':
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const me.MyHomeScreen()),
            );
            break;
          case 'caregiver':
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const carer.CarerHomeScreen()),
            );
            break;
          case 'staff':
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (_) => const center.CenterHomeScreen()),
            );
            break;
          default:
            showMessageBanner(context, '알 수 없는 역할입니다.');
        }
      } else {
        showMessageBanner(context, resp.message);
      }
    } catch (_) {
      if (!mounted) return;
      showMessageBanner(context, '서버에 연결할 수 없습니다.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Text(
                  widget.loginType == LoginType.user
                      ? '나의 생활 패턴 분석 서비스'
                      : '모니터링 케어 서비스',
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 20),
                const Text('로그인',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('아이디, 비밀번호를 입력해주세요',
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 60),

                // 아이디 입력
                TextField(
                  controller: _idController,
                  decoration: const InputDecoration(
                    labelText: '아이디:',
                    hintText: '입력해주세요',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // 비밀번호 입력
                TextField(
                  controller: _pwController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호:',
                    hintText: '입력해주세요',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // 자동로그인 체크박스
                Row(
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: _autoLogin,
                      builder: (context, value, _) {
                        return Checkbox(
                          value: value,
                          onChanged: (v) => _autoLogin.value = v ?? false,
                        );
                      },
                    ),
                    const Text('자동 로그인'),
                  ],
                ),

                // 비밀번호 찾기 / 회원가입 링크
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FindPasswordScreen(loginType: widget.loginType),
                        ),
                      ),
                      child: const Text('비밀번호 찾기',
                          style: TextStyle(color: Colors.grey)),
                    ),
                    const Text('|'),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SignupScreen(loginType: widget.loginType),
                        ),
                      ),
                      child: const Text('회원가입',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onLoginPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(160, 50),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('로그인',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
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
