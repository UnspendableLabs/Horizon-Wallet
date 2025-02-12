import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';

class HorizonGradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String buttonText;
  final bool isDarkMode;

  const HorizonGradientButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: isDarkMode
                ? const [
                    createButtonDarkGradient1,
                    createButtonDarkGradient2,
                    createButtonDarkGradient3,
                    createButtonDarkGradient4,
                  ]
                : const [
                    createButtonLightGradient1,
                    createButtonLightGradient2,
                    createButtonLightGradient3,
                    createButtonLightGradient4,
                  ],
            stops: isDarkMode
                ? const [0.0, 0.325, 0.65, 1.0]
                : const [0.0, 0.326, 0.652, 0.9879],
            transform:
                isDarkMode ? null : const GradientRotation(139.18 * pi / 180),
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.all(20),
          ),
          onPressed: onPressed,
          child: Text(
            buttonText,
            style: TextStyle(
              color: isDarkMode ? Colors.black : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class HorizonOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String buttonText;
  final bool isDarkMode;

  const HorizonOutlinedButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              isDarkMode ? importButtonDarkBackground : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: isDarkMode
                ? BorderSide.none
                : const BorderSide(
                    width: 1,
                    color: Colors.black,
                  ),
          ),
          padding: const EdgeInsets.all(20),
        ),
        onPressed: onPressed,
        child: Text(
          buttonText,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
