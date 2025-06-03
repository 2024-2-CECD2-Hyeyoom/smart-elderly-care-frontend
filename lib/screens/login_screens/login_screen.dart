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

// 홈스크린을 별칭(import-as)으로 불러옵니다.
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
    // BuildContext를 async gap에 안전하게 넘기기 위해 복사해 놓습니다.
    final ctx = context;
    setState(() => _isLoading = true);

    final phone = _idController.text.trim();
    final password = _pwController.text;
    if (phone.isEmpty || password.isEmpty) {
      showMessageBanner(ctx, '아이디와 비밀번호를 모두 입력해주세요.');
      setState(() => _isLoading = false);
      return;
    }

    try {
      final req = LoginRequest(phone: phone, password: password);
      final resp = await AuthService.instance.login(req);

      if (!mounted) return;
      if (resp.isSuccess && resp.result != null) {
        // 1) 토큰 저장 (AuthService.login 내부에서도 이미 저장하지만, 혹시 모르니 재확인)
        await SecureStorageService.writeToken(resp.result!.token);

        // 2) loginResponse에서 받은 memberId와 role로 분기
        final role = resp.result!.role;
        final userId = resp.result!.memberId;
        final counselorName = resp.result!.name;

        switch (role) {
          case 'USER':
            Navigator.of(ctx).pushReplacement(
              MaterialPageRoute(
                builder: (_) => me.MyHomeScreen(userId: userId),
              ),
            );
            break;
          case 'CAREGIVER':
            Navigator.of(ctx).pushReplacement(
              MaterialPageRoute(
                builder: (_) => carer.CarerHomeScreen(
                  memberId: userId,
                  counselorName: counselorName,
                ),
              ),
            );
            break;
          case 'STAFF':
            Navigator.of(ctx).pushReplacement(
              MaterialPageRoute(
                builder: (_) => center.CenterHomeScreen(
                  memberId: userId,
                  counselorName: counselorName,
                ),
              ),
            );
            break;
          default:
            showMessageBanner(ctx, '알 수 없는 역할입니다.');
        }
      } else {
        showMessageBanner(ctx, resp.message);
      }
    } catch (_) {
      if (!mounted) return;
      showMessageBanner(ctx, '서버에 연결할 수 없습니다.');
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
