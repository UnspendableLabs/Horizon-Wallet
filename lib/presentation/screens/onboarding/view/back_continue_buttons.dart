import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';

class BackContinueButtons extends StatelessWidget {
  final bool isDarkMode;
  final bool isSmallScreenWidth;
  final VoidCallback onPressedBack;
  final String backButtonText;
  final VoidCallback onPressedContinue;
  final String continueButtonText;
  final Widget? errorWidget;

  const BackContinueButtons(
      {super.key,
      required this.isDarkMode,
      required this.isSmallScreenWidth,
      required this.onPressedBack,
      required this.onPressedContinue,
      required this.backButtonText,
      required this.continueButtonText,
      this.errorWidget});

  @override
  Widget build(BuildContext context) {
    final cancelButtonBackgroundColor =
        isDarkMode ? noBackgroundColor : lightThemeInputColor;
    final continueButtonBackgroundColor =
        isDarkMode ? mediumNavyDarkTheme : royalBlueLightTheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: SizedBox(
              width: isSmallScreenWidth ? double.infinity : 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  overlayColor: noBackgroundColor,
                  elevation: 0,
                  backgroundColor: cancelButtonBackgroundColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ), // Text style
                ),
                onPressed: onPressedBack,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(backButtonText,
                      style: TextStyle(
                          color: isDarkMode ? mainTextGrey : mainTextBlack)),
                ),
              ),
            ),
          ),
          if (errorWidget != null) errorWidget!,
          Flexible(
            child: SizedBox(
              width: isSmallScreenWidth ? double.infinity : 250,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: continueButtonBackgroundColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w500),
                ),
                onPressed: onPressedContinue,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    continueButtonText,
                    style: TextStyle(
                        color: isDarkMode ? neonBlueDarkTheme : mainTextWhite),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
