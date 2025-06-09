import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/screens/login_screens/login_screen.dart';
import 'package:frontend/widgets/custom_pop_up.dart';
import 'package:frontend/widgets/custom_snackbar.dart';
import 'package:frontend/models/user_signup_request.dart';
import 'package:frontend/models/user_signup_response.dart';
import 'package:frontend/models/staff_signup_request.dart';
import 'package:frontend/models/caregiver_signup_request.dart';
import 'package:frontend/models/welfare_center.dart';
import 'package:frontend/services/signup_service.dart';
import 'package:frontend/services/welfare_center_service.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.length > 11) {
      digits = digits.substring(0, 11);
    }

    String formatted = digits;
    if (digits.length >= 4 && digits.length <= 7) {
      formatted = '${digits.substring(0, 3)}-${digits.substring(3)}';
    } else if (digits.length >= 8) {
      formatted =
      '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

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
  final passwordController = TextEditingController();
  final yearController = TextEditingController();
  final monthController = TextEditingController();
  final dayController = TextEditingController();
  final addressController = TextEditingController();
  final defaultCareCodeController = TextEditingController();
  List<TextEditingController> extraCareCodeControllers = [];

  late final LoginType loginType;
  final _signupService = SignupService();
  final _welfareService = WelfareCenterService();

  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    loginType = widget.loginType;
  }

  bool validateFieldsForSignup() {
    if (nameController.text.trim().isEmpty ||
        contactController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        yearController.text.trim().isEmpty ||
        monthController.text.trim().isEmpty ||
        dayController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        welfareCenter == null ||
        welfareCenter!.isEmpty) {
      return true;
    }
    if (welfareCenter == '아니오') {
      if (defaultCareCodeController.text.trim().isEmpty) return true;
      for (var c in extraCareCodeControllers) {
        if (c.text.trim().isEmpty) return true;
      }
    }
    return false;
  }

  bool isValidPassword(String password) {
    // 최소 8자, 대소문자, 숫자, 특수문자 포함 여부 검사
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*()_+{}\[\]:;<>,.?~\\/-]).{8,}$');
    return regex.hasMatch(password);
  }

  Future<void> _onSelectCenter() async {
    final messenger = ScaffoldMessenger.of(context);
    late List<WelfareCenter> all;
    try {
      all = await _welfareService.fetchAll();
    } catch (_) {
      if (!mounted) return;
      messenger
          .showSnackBar(const SnackBar(content: Text('복지센터 목록을 불러오지 못했습니다.')));
      return;
    }
    if (!mounted) return;

    final sidoList = [
      '전체',
      ...{for (var c in all) c.sido}
    ];
    String selectedSido = '전체';
    List<String> sigunguList = [];
    String selectedSigungu = '전체';
    List<WelfareCenter> filtered = all;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('기관 검색'),
          content: SizedBox(
            height: 400, // 또는 적절한 높이
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                        filtered = (sigungu == '전체')
                            ? await _welfareService.fetchBySido(selectedSido)
                            : await _welfareService.fetchBySidoSigungu(
                            selectedSido, sigungu);
                        setState(() {});
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                        hintText: '기관명을 입력하세요',
                        prefixIcon: Icon(Icons.search)),
                    onChanged: (q) => setState(() {
                      filtered = filtered
                          .where((c) => c.organName.contains(q.trim()))
                          .toList();
                    }),
                  ),
                  const SizedBox(height: 10),
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
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('닫기'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSignupPressed() async {
    if (validateFieldsForSignup()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('모든 정보를 입력해주세요')));
      return;
    }

    final name = nameController.text.trim();
    final phone = contactController.text.replaceAll('-', '').trim();
    final genderVal = gender == '남' ? 1 : 0;
    final address = addressController.text.trim();
    final welfareCenterName = selectedInstitutionName;
    final password = passwordController.text.trim();
    if (!isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호는 8자 이상이며, 영문 대소문자, 숫자, 특수문자를 모두 포함해야 합니다.')),
      );
      return;
    }

    late UserSignupResponse resp;
    try {
      if (welfareCenter == '예') {
        final req = StaffSignupRequest(
          name: name,
          phone: phone,
          gender: genderVal,
          address: address,
          welfareCenterName: welfareCenterName,
          password: password,
        );
        resp = await _signupService.signupStaff(req);
      } else if (welfareCenter == '아니오') {
        final ids = [
          defaultCareCodeController.text.trim(),
          ...extraCareCodeControllers.map((c) => c.text.trim())
        ];
        final req = CaregiverSignupRequest(
          name: name,
          phone: phone,
          gender: genderVal,
          address: address,
          elderlyIds: ids,
          password: password,
        );
        resp = await _signupService.signupCaregiver(req);
      } else {
        // 일반 user
        final req = UserSignupRequest(
          name: name,
          phone: phone,
          gender: genderVal,
          birthDate:
              '${yearController.text}-${monthController.text.padLeft(2, '0')}-${dayController.text.padLeft(2, '0')}',
          address: address,
          welfareCenterName: welfareCenterName,
          underlyingDiseases: extraCareCodeControllers
              .map((c) => c.text.trim())
              .where((s) => s.isNotEmpty)
              .toList(),
          password: password,
        );
        resp = await _signupService.signupUser(req);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('서버에 연결할 수 없습니다.')));
      return;
    }
    if (!mounted) return;

    if (resp.isSuccess) {
      showDialog(
        context: context,
        builder: (_) => CustomDialog(
          content: '회원가입이 완료되었습니다.\n로그인 페이지로 돌아갑니다.',
          onConfirm: () async {
            await storage.delete(key: 'accessToken');
            Navigator.of(context).pop(); // 다이얼로그 닫기
            Navigator.of(context).pop(); // 회원가입 화면 닫기
            // 로그인 화면으로 다시 이동하면서 loginType을 그대로 전달
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => LoginScreen(loginType: widget.loginType),
              ),
            );
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(resp.message)));
    }
  }

  Widget _buildLabeledInput(String label, TextEditingController ctl,
      {Widget? suffix}) {
    return TextField(
      controller: ctl,
      decoration: InputDecoration(
        labelText: label,
        hintText: '입력해주세요',
        border: const UnderlineInputBorder(),
        suffixIcon: suffix,
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
                const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text('모든 정보를 입력해주세요',
                      style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 15),
                _buildLabeledInput('이름', nameController),
                const SizedBox(height: 12),
                const Text('성별:'),
                Row(
                  children: [
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
                const SizedBox(height: 12),
                const Text('생년월일'),
                const SizedBox(height: 8),
                BirthInput(
                  yearController: yearController,
                  monthController: monthController,
                  dayController: dayController,
                ),
                const SizedBox(height: 25),
                _buildLabeledInput('집 주소', addressController),
                const SizedBox(height: 12),
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
                TextField(
                  controller: contactController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [PhoneNumberFormatter()],
                  decoration: const InputDecoration(
                    labelText: '전화번호',
                    hintText: '01012345678',
                    border: OutlineInputBorder(),
                  ),
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
