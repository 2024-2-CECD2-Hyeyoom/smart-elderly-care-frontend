// lib/screens/login_screens/sign_up_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screens/login_screen.dart';
import 'package:frontend/widgets/custom_pop_up.dart';
import 'package:frontend/widgets/custom_snackbar.dart';
import 'package:frontend/models/user_signup_request.dart';
import 'package:frontend/models/user_signup_response.dart';
import 'package:frontend/models/welfare_center.dart';
import 'package:frontend/services/signup_service.dart';
import 'package:frontend/services/welfare_center_service.dart';

class SignupScreen extends StatefulWidget {
  final LoginType loginType;
  const SignupScreen({super.key, required this.loginType});

  @override
  State<SignupScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignupScreen> {
  String? gender = '';
  String? welfareCenter = '';
  String selectedInstitutionName = '';
  String? _idStatusMessage;
  Color? _idStatusColor;

  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  final yearController = TextEditingController();
  final monthController = TextEditingController();
  final dayController = TextEditingController();
  final defaultCareCodeController = TextEditingController();
  List<TextEditingController> extraCareCodeControllers = [];

  late final LoginType loginType;
  final _signupService = SignupService();
  final _welfareService = WelfareCenterService();

  @override
  void initState() {
    super.initState();
    loginType = widget.loginType;
  }

  bool validateFieldsForSignup() {
    final basicEmpty = nameController.text.trim().isEmpty ||
        contactController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        yearController.text.trim().isEmpty ||
        monthController.text.trim().isEmpty ||
        dayController.text.trim().isEmpty ||
        welfareCenter == null ||
        welfareCenter!.isEmpty ||
        idController.text.trim().isEmpty;
    return basicEmpty;
  }

  Future<void> _onSelectCenter() async {
    // ① messenger 미리 저장
    final messenger = ScaffoldMessenger.of(context);

    // ② fetch 전에 mounted 체크는 불필요, fetch 후에 체크
    late List<WelfareCenter> all;
    try {
      all = await _welfareService.fetchAll();
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('복지센터 목록을 불러오지 못했습니다.')),
      );
      return;
    }
    if (!mounted) return;

    // 시도 목록
    final sidoList = [
      '전체',
      ...{for (var c in all) c.sido}
    ];
    String selectedSido = '전체';
    // 시·군구 목록
    List<String> sigunguList = [];
    String selectedSigungu = '전체';
    // 결과 리스트 초기값
    List<WelfareCenter> filtered = all;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('기관 검색'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1) 시도 드롭다운
                DropdownButton<String>(
                  value: selectedSido,
                  items: sidoList
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (sido) async {
                    if (sido == null) return;
                    setState(() {
                      selectedSido = sido;
                      selectedSigungu = '전체';
                      sigunguList = [];
                    });

                    if (sido == '전체') {
                      filtered = all;
                    } else {
                      final list = await _welfareService.fetchBySido(sido);
                      filtered = list;
                      sigunguList = [
                        '전체',
                        ...{for (var c in list) c.sigungu}
                      ];
                    }
                    setState(() {});
                  },
                ),

                // 2) 시군구 드롭다운
                if (selectedSido != '전체') ...[
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: selectedSigungu,
                    items: sigunguList
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (sigungu) async {
                      if (sigungu == null) return;
                      setState(() => selectedSigungu = sigungu);

                      if (sigungu == '전체') {
                        filtered =
                            await _welfareService.fetchBySido(selectedSido);
                      } else {
                        filtered = await _welfareService.fetchBySidoSigungu(
                            selectedSido, sigungu);
                      }
                      setState(() {});
                    },
                  ),
                ],

                const SizedBox(height: 12),
                // 3) 이름 검색
                TextField(
                  decoration: const InputDecoration(
                    hintText: '기관명을 입력하세요',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (q) => setState(() {
                    filtered = filtered
                        .where((c) => c.organName.contains(q.trim()))
                        .toList();
                  }),
                ),

                const SizedBox(height: 10),
                // 4) 결과 리스트
                SizedBox(
                  height: 200,
                  child: filtered.isEmpty
                      ? const Center(child: Text('검색 결과가 없습니다'))
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final c = filtered[i];
                            return ListTile(
                              title: Text(c.organName),
                              subtitle: Text('${c.sido} ${c.sigungu}'),
                              onTap: () {
                                setState(() {
                                  selectedInstitutionName = c.organName;
                                });
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('닫기'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _onSignupPressed() async {
    if (validateFieldsForSignup()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 정보를 입력해주세요')),
      );
      return;
    }

    final request = UserSignupRequest(
      name: nameController.text.trim(),
      phone: contactController.text.trim(),
      gender: gender == '남' ? 1 : 0,
      birthDate:
          '${yearController.text}-${monthController.text.padLeft(2, '0')}-${dayController.text.padLeft(2, '0')}',
      address: selectedInstitutionName,
      welfareCenterName: selectedInstitutionName,
      underlyingDiseases: extraCareCodeControllers
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      password: passwordController.text.trim(),
    );

    late UserSignupResponse response;
    try {
      response = await _signupService.signupUser(request);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서버에 연결할 수 없습니다.')),
      );
      return;
    }

    if (!mounted) return;

    if (response.isSuccess) {
      showDialog(
        context: context,
        builder: (_) => CustomDialog(
          content: '회원가입이 완료되었습니다.\n로그인 페이지로 돌아갑니다.',
          onConfirm: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );
    }
  }

  Widget _buildLabeledInput(
    String label,
    TextEditingController controller, {
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: '입력해주세요',
        suffixIcon: suffix,
        border: const UnderlineInputBorder(),
      ),
    );
  }

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
          '회원가입',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text('모든 정보를 입력해주세요',
                      style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 15),

                // 이름
                _buildLabeledInput('이름', nameController),

                // 성별
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('성별:'),
                    const SizedBox(width: 10),
                    Radio<String>(
                      value: '남',
                      groupValue: gender,
                      onChanged: (v) => setState(() => gender = v),
                    ),
                    const Text('남'),
                    Radio<String>(
                      value: '여',
                      groupValue: gender,
                      onChanged: (v) => setState(() => gender = v),
                    ),
                    const Text('여'),
                  ],
                ),

                // 생년월일
                const SizedBox(height: 12),
                const Text('생년월일'),
                const SizedBox(height: 8),
                BirthInput(
                  yearController: yearController,
                  monthController: monthController,
                  dayController: dayController,
                ),

                // 복지센터 등록 여부
                const SizedBox(height: 25),
                if (loginType == LoginType.user) ...[
                  const Text('관리(의료/복지) 기관 등록 여부:'),
                  Row(
                    children: [
                      Radio<String>(
                        value: '등록',
                        groupValue: welfareCenter,
                        onChanged: (v) => setState(() => welfareCenter = v),
                      ),
                      const Text('등록'),
                      Radio<String>(
                        value: '미등록',
                        groupValue: welfareCenter,
                        onChanged: (v) => setState(() => welfareCenter = v),
                      ),
                      const Text('미등록'),
                    ],
                  ),
                ] else ...[
                  const Text('관리(의료/복지) 기관에 속한 보호자인가요?:'),
                  Row(
                    children: [
                      Radio<String>(
                        value: '예',
                        groupValue: welfareCenter,
                        onChanged: (v) => setState(() => welfareCenter = v),
                      ),
                      const Text('예'),
                      Radio<String>(
                        value: '아니오',
                        groupValue: welfareCenter,
                        onChanged: (v) => setState(() => welfareCenter = v),
                      ),
                      const Text('아니오'),
                    ],
                  ),
                  if (welfareCenter == '아니오') ...[
                    const SizedBox(height: 12),
                    const Text('케어 대상자의 코드를 입력해주세요'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: defaultCareCodeController,
                      decoration: const InputDecoration(
                        hintText: '코드 입력',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (extraCareCodeControllers.isNotEmpty)
                      const SizedBox(height: 8),
                    ...extraCareCodeControllers.asMap().entries.map((e) =>
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextField(
                            controller: e.value,
                            decoration: InputDecoration(
                              hintText: '추가 코드 입력',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    extraCareCodeControllers.removeAt(e.key);
                                  });
                                },
                              ),
                            ),
                          ),
                        )),
                    Center(
                      child: IconButton(
                        onPressed: () => setState(() => extraCareCodeControllers
                            .add(TextEditingController())),
                        icon: const Icon(
                          Icons.add_circle_outline,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 12),

                if (welfareCenter == '등록' || welfareCenter == '예') ...[
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            selectedInstitutionName.isEmpty
                                ? '선택된 기관 없음'
                                : selectedInstitutionName,
                            style: TextStyle(
                              color: selectedInstitutionName.isEmpty
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _onSelectCenter,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('기관 찾기'),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                _buildLabeledInput('전화번호', contactController),

                const SizedBox(height: 12),

                // 아이디 중복확인
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabeledInput(
                      '아이디',
                      idController,
                      suffix: TextButton(
                        onPressed: () {
                          final id = idController.text.trim();
                          if (id.isEmpty) {
                            showMessageBanner(context, '아이디를 입력해주세요.');
                            return;
                          }
                          final ok = id != 'test';
                          setState(() {
                            _idStatusMessage = ok ? '사용 가능한 아이디입니다.' : '사용 불가';
                            _idStatusColor = ok ? Colors.green : Colors.red;
                          });
                        },
                        child:
                            const Text('중복 확인', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    if (_idStatusMessage != null) ...[
                      const SizedBox(height: 4),
                      Text(_idStatusMessage!,
                          style:
                              TextStyle(color: _idStatusColor, fontSize: 13)),
                    ]
                  ],
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    hintText: '입력해주세요',
                  ),
                ),

                const SizedBox(height: 30),

                Center(
                  child: ElevatedButton(
                    onPressed: _onSignupPressed,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(180, 48),
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      '가입하기',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// BirthInput 위젯
class BirthInput extends StatelessWidget {
  final TextEditingController yearController;
  final TextEditingController monthController;
  final TextEditingController dayController;

  const BirthInput({
    super.key,
    required this.yearController,
    required this.monthController,
    required this.dayController,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildDateField({
      required TextEditingController controller,
      required String hint,
      required double width,
    }) {
      return SizedBox(
        width: width,
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: hint == 'YYYY' ? 4 : 2,
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          ),
        ),
      );
    }

    return Row(
      children: [
        buildDateField(controller: yearController, hint: 'YYYY', width: 80),
        const SizedBox(width: 8),
        buildDateField(controller: monthController, hint: 'MM', width: 60),
        const SizedBox(width: 8),
        buildDateField(controller: dayController, hint: 'DD', width: 60),
      ],
    );
  }
}
