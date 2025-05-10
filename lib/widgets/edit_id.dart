import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_snackbar.dart';

// 마이페이지에서 아이디 수정하는 기능 위젯

class EditIdField extends StatefulWidget {
  final String initialId;
  final void Function(String newId)? onSave;

  const EditIdField({
    super.key,
    required this.initialId,
    this.onSave,
  });

  @override
  State<EditIdField> createState() => _EditableIdFieldState();
}

class _EditableIdFieldState extends State<EditIdField> {
  bool _isEditing = false;
  final TextEditingController _controller = TextEditingController();
  String? _statusMessage;
  Color? _statusColor;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialId;
  }

  void _checkDuplicate() {
    final id = _controller.text.trim();

    if (id.isEmpty) {
      showMessageBanner(context, '아이디를 입력해주세요.');
      return;
    }

    final isAvailable = id != 'test';

    setState(() {
      _statusMessage = isAvailable ? '사용 가능한 아이디입니다.' : '사용 불가능한 아이디입니다.';
      _statusColor = isAvailable ? Colors.green : Colors.red;
    });
  }

  void _save() {
    if (_statusColor == Colors.green) {
      widget.onSave?.call(_controller.text.trim());
      setState(() {
        _isEditing = false;
        _statusMessage = null;
      });
    } else {
      showMessageBanner(context, '아이디 중복 확인이 필요합니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade100,
          ),
          child: Row(
            children: [
              Expanded(
                child: _isEditing
                    ? TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: '아이디를 입력해주세요',
                          suffixIcon: TextButton(
                            onPressed: _checkDuplicate,
                            child: const Text('중복 확인',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 48, 81, 120),
                                )),
                          ),
                        ),
                      )
                    : Text('아이디: ${_controller.text}',
                        style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 8),
              _isEditing
                  ? TextButton(
                      onPressed: _save,
                      child: const Text(
                        '저장',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    )
                  : TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      icon: const Icon(Icons.edit,
                          size: 18, color: Color(0xFF305178)),
                      label: const Text(
                        '수정',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF305178)),
                      ),
                    ),
            ],
          ),
        ),
        if (_statusMessage != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8),
            child: Text(
              _statusMessage!,
              style: TextStyle(color: _statusColor, fontSize: 13),
            ),
          ),
      ],
    );
  }
}
