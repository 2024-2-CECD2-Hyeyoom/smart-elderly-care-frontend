import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screens/login_screen.dart';
import 'package:frontend/widgets/custom_popUp.dart';
import 'package:frontend/widgets/custom_snackbar.dart';

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

  late final LoginType loginType;

  List<TextEditingController> extraCareCodeControllers = [];

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
  void initState() {
    super.initState();
    loginType = widget.loginType;
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
        onTap: () {
          // 입력창 포커스 해제 → 키보드 닫힘
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Column(
                    children: [
                      Text('모든 정보를 입력해주세요',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
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
                      onChanged: (value) {
                        setState(() {
                          gender = value;
                        });
                      },
                    ),
                    const Text('남'),
                    Radio<String>(
                      value: '여',
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value;
                        });
                      },
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

                // 관리 기관 유무
                const SizedBox(height: 25),

                if (loginType == LoginType.user) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('관리(의료/복지) 기관 등록 여부:'),
                      Row(
                        children: [
                          Radio<String>(
                            value: '등록',
                            groupValue: welfareCenter,
                            onChanged: (value) {
                              setState(() {
                                welfareCenter = value;
                              });
                            },
                          ),
                          const Text('등록'),
                          Radio<String>(
                            value: '미등록',
                            groupValue: welfareCenter,
                            onChanged: (value) {
                              setState(() {
                                welfareCenter = value;
                              });
                            },
                          ),
                          const Text('미등록'),
                        ],
                      ),
                    ],
                  ),
                ] else if (loginType == LoginType.admin) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('관리(의료/복지) 기관에 속한 보호자인가요?:'),
                      Row(
                        children: [
                          Radio<String>(
                            value: '예',
                            groupValue: welfareCenter,
                            onChanged: (value) {
                              setState(() {
                                welfareCenter = value;
                              });
                            },
                          ),
                          const Text('예'),
                          Radio<String>(
                            value: '아니오',
                            groupValue: welfareCenter,
                            onChanged: (value) {
                              setState(() {
                                welfareCenter = value;
                              });
                            },
                          ),
                          const Text('아니오'),
                        ],
                      ),
                      if (welfareCenter == '아니오') ...[
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '케어 대상자의 코드를 입력해주세요',
                            ),
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
                            // ✅ 동적으로 추가된 입력란들 (삭제 가능)
                            Column(
                              children: List.generate(
                                  extraCareCodeControllers.length, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: TextField(
                                    controller: extraCareCodeControllers[index],
                                    decoration: InputDecoration(
                                      hintText: '추가 코드 입력',
                                      border: const OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.grey),
                                        onPressed: () {
                                          setState(() {
                                            extraCareCodeControllers
                                                .removeAt(index);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      extraCareCodeControllers
                                          .add(TextEditingController());
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    size: 30,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // 등록 / 예 일 때만 기관 찾기 표시
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
                        onPressed: () async {
                          await showInstitutionSearchDialog(context,
                              (selectedName) {
                            setState(() {
                              selectedInstitutionName = selectedName;
                            });
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('기관 찾기'),
                      ),
                    ],
                  ),
                ],

                // 전화번호
                _buildLabeledInput('전화번호', contactController),

                const SizedBox(height: 12),

                // 아이디 입력 + 중복 확인 버튼
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

                          // 중복확인예시용 아이디
                          final isAvailable = id != "test";

                          setState(() {
                            if (isAvailable) {
                              _idStatusMessage = '사용 가능한 아이디입니다.';
                              _idStatusColor = Colors.green;
                            } else {
                              _idStatusMessage = '사용 불가능한 아이디입니다.';
                              _idStatusColor = Colors.red;
                            }
                          });
                        },
                        child:
                            const Text('중복 확인', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    if (_idStatusMessage != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _idStatusMessage!,
                        style: TextStyle(
                          color: _idStatusColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),

                // 비밀번호
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    hintText: '입력해주세요',
                  ),
                ),

                // 가입하기 버튼
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // 가입 로직 추가 예정, 임시로 가입 완료 팝업
                      showDialog(
                        context: context,
                        builder: (_) => const CustomDialog(
                            content: '회원가입이 완료되었습니다. \n로그인을 진행해주세요.'),
                      );
                    },
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
    return Row(
      children: [
        _buildDateField(controller: yearController, hint: 'YYYY', width: 80),
        const SizedBox(width: 8),
        _buildDateField(controller: monthController, hint: 'MM', width: 60),
        const SizedBox(width: 8),
        _buildDateField(controller: dayController, hint: 'DD', width: 60),
      ],
    );
  }

  Widget _buildDateField({
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
}

// 추후 데이터베이스에 직접 등록 후 검색할 수 있도록 변경 필요
Future<void> showInstitutionSearchDialog(
    BuildContext context, Function(String) onInstitutionSelected) async {
  final TextEditingController searchController = TextEditingController();
  final List<String> dummyResults = [
    "서울 행복복지센터",
    "강남 노인복지관",
    "진주 강남복지센터",
    "사랑의 집",
    "희망복지회관"
  ];

  List<String> filteredResults = [];

  await showDialog(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('기관 검색'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: '기관명을 입력하세요',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          filteredResults = dummyResults
                              .where((element) =>
                                  element.contains(searchController.text))
                              .toList();
                        });
                      },
                    ),
                  ),
                  onSubmitted: (_) {
                    setState(() {
                      filteredResults = dummyResults
                          .where((element) =>
                              element.contains(searchController.text))
                          .toList();
                    });
                  },
                ),
                const SizedBox(height: 10),
                ...filteredResults.map((e) => ListTile(
                      title: Text(e),
                      onTap: () {
                        Navigator.pop(context);
                        onInstitutionSelected(e);
                      },
                    )),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('닫기'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        },
      );
    },
  );
}
