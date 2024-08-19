import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';

class HorizonCancelButton extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onPressed;
  final String? buttonText;

  const HorizonCancelButton(
      {super.key,
      required this.isDarkMode,
      required this.onPressed,
      this.buttonText});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        overlayColor: noBackgroundColor,
        elevation: 0,
        backgroundColor: isDarkMode ? noBackgroundColor : lightThemeInputColor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(buttonText ?? 'CANCEL',
            style: TextStyle(color: isDarkMode ? mainTextGrey : mainTextBlack)),
      ),
    );
  }
}
