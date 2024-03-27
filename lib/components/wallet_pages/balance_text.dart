import 'package:flutter/material.dart';

class BalanceText extends StatelessWidget {
  final String text;
  final Alignment alignment;
  const BalanceText({required this.text, required this.alignment, super.key});
  @override
  Widget build(context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 45),
      child: Align(
          alignment: alignment,
          child: Text(
            style: const TextStyle(color: Colors.white, fontSize: 20),
            text,
          )),
    );
  }
}
