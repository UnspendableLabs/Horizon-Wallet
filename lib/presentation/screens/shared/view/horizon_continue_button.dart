import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';

class HorizonContinueButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? buttonText;
  final bool loading;

  const HorizonContinueButton({
    super.key,
    required this.onPressed,
    this.buttonText,
    this.loading = false,
  });

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
      onPressed: loading ? null : onPressed,
      child: loading
          ? Center(
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  buttonText ?? 'CONTINUE',
                  style: TextStyle(
                      color: isDarkMode ? neonBlueDarkTheme : mainTextWhite),
                ),
              ],
            ))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                buttonText ?? 'CONTINUE',
                style: TextStyle(
                    color: isDarkMode ? neonBlueDarkTheme : mainTextWhite),
              ),
            ),
    );
  }
}
