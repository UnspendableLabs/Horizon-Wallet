import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class GradientAvatar extends StatelessWidget {
  final String input;
  final double radius;

  const GradientAvatar({required this.input, this.radius = 24.0, super.key});

  List<Color> _generateColors(String input) {
    final hash = sha256.convert(utf8.encode(input)).bytes;

    Color colorFromHash(int offset) {
      return Color.fromARGB(
        255,
        hash[offset] % 256,
        hash[offset + 1] % 256,
        hash[offset + 2] % 256,
      );
    }

    return [
      colorFromHash(0),
      colorFromHash(3),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = _generateColors(input);

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

