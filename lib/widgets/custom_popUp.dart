import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final VoidCallback? onConfirm;

  const CustomDialog({
    super.key,
    this.title = '알림',
    required this.content,
    this.confirmText = '확인',
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onConfirm != null) onConfirm!();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}
