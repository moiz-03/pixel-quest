import 'package:flutter/material.dart';

class SplashFittedText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const SplashFittedText({super.key, required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(text, textAlign: TextAlign.center, style: style),
    );
  }
}
