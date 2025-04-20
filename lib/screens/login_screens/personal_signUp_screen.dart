import 'package:flutter/material.dart';

class PersonalSignupScreen extends StatefulWidget {
  const PersonalSignupScreen({super.key});

  @override
  State<PersonalSignupScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<PersonalSignupScreen> {
  String? gender = '남';
  String selectedCenter = '선택해주세요';
  String? welfareCenter = '유';
  String selectedInstitutionName = '';
  DateTime? birthDate;

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final contactController = TextEditingController();
  final conditionController = TextEditingController();
  final passwordController = TextEditingController();
  final yearController = TextEditingController();
  final monthController = TextEditingController();
  final dayController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('관리(복지) 기관 계약:'),
                    const SizedBox(width: 10),
                    Radio<String>(
                      value: '유',
                      groupValue: welfareCenter,
                      onChanged: (value) {
                        setState(() {
                          welfareCenter = value;
                        });
                      },
                    ),
                    const Text('유'),
                    Radio<String>(
                      value: '무',
                      groupValue: welfareCenter,
                      onChanged: (value) {
                        setState(() {
                          welfareCenter = value;
                        });
                      },
                    ),
                    const Text('무'),
                  ],
                ),
                // 기관 찾기
                // 기관 계약 유 일때만 보임
                if (welfareCenter == '유') ...[
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
                                    : Colors.black),
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
                const SizedBox(height: 12),

                // 전화번호
                _buildLabeledInput('전화번호', contactController),

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
                      // 가입 로직
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

  Widget _buildLabeledInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: '입력해주세요',
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
          counterText: '', // 글자 수 아래 표시 제거
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
                        onInstitutionSelected(e); // 선택 콜백
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
