import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';

class HorizonContinueButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? buttonText;

  const HorizonContinueButton(
      {super.key, required this.onPressed, this.buttonText});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: isDarkMode ? mediumNavyDarkTheme : royalBlueLightTheme,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          buttonText ?? 'CONTINUE',
          style:
              TextStyle(color: isDarkMode ? neonBlueDarkTheme : mainTextWhite),
        ),
      ),
    );
  }
}
