import 'package:flutter/material.dart';

Future<void> showCustomPopUp({
  required BuildContext context,
  String title = '알림',
  required String content,
  String confirmText = '확인',
  VoidCallback? onConfirm,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false, // 바깥 터치로 닫힘 방지
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 팝업 닫기
              if (onConfirm != null) onConfirm();
            },
            child: Text(confirmText),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );
    },
  );
}
