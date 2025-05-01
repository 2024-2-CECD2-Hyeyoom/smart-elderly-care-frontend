import 'package:flutter/material.dart';

class CustomMessageBanner extends StatelessWidget {
  final String message;
  final Color backgroundColor;

  const CustomMessageBanner({
    super.key,
    required this.message,
    this.backgroundColor = const Color(0xFF323232), // Flutter 기본 SnackBar 색
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // 투명 배경
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: backgroundColor,
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}

void showMessageBanner(
  BuildContext context,
  String message, {
  Color backgroundColor = const Color(0xFF323232),
}) {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 0, // SnackBar처럼 하단에 고정
      left: 0,
      right: 0,
      child: CustomMessageBanner(
        message: message,
        backgroundColor: backgroundColor,
      ),
    ),
  );

  overlay.insert(entry);

  Future.delayed(const Duration(seconds: 2), () {
    entry.remove();
  });
}
