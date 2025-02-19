import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';

class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final Color inputBackground;
  final Color inputBackgroundEmpty;
  final Color inputBorderColor;
  final Color inputTextColor;
  final Color errorColor;
  final Color errorBackgroundColor;

  const CustomThemeExtension({
    required this.inputBackground,
    required this.inputBackgroundEmpty,
    required this.inputBorderColor,
    required this.inputTextColor,
    required this.errorColor,
    required this.errorBackgroundColor,
  });

  static const light = CustomThemeExtension(
    inputBackground: inputLightBackground,
    inputBackgroundEmpty: lightThemeBackgroundColor,
    inputBorderColor: inputLightBorderColor,
    inputTextColor: Colors.black,
    errorColor: redErrorTextColor,
    errorBackgroundColor: redErrorTextTransparentLight,
  );

  static const dark = CustomThemeExtension(
    inputBackground: inputDarkBackground,
    inputBackgroundEmpty: darkThemeBackgroundColor,
    inputBorderColor: inputDarkBorderColor,
    inputTextColor: Colors.white,
    errorColor: redErrorTextColor,
    errorBackgroundColor: redErrorTextTransparentDark,
  );

  @override
  ThemeExtension<CustomThemeExtension> copyWith({
    Color? inputBackground,
    Color? inputBackgroundEmpty,
    Color? inputBorderColor,
    Color? inputTextColor,
    Color? errorColor,
    Color? errorBackgroundColor,
  }) {
    return CustomThemeExtension(
      inputBackground: inputBackground ?? this.inputBackground,
      inputBackgroundEmpty: inputBackgroundEmpty ?? this.inputBackgroundEmpty,
      inputBorderColor: inputBorderColor ?? this.inputBorderColor,
      inputTextColor: inputTextColor ?? this.inputTextColor,
      errorColor: errorColor ?? this.errorColor,
      errorBackgroundColor: errorBackgroundColor ?? this.errorBackgroundColor,
    );
  }

  @override
  ThemeExtension<CustomThemeExtension> lerp(
    covariant ThemeExtension<CustomThemeExtension>? other,
    double t,
  ) {
    if (other is! CustomThemeExtension) {
      return this;
    }
    return CustomThemeExtension(
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      inputBackgroundEmpty:
          Color.lerp(inputBackgroundEmpty, other.inputBackgroundEmpty, t)!,
      inputBorderColor:
          Color.lerp(inputBorderColor, other.inputBorderColor, t)!,
      inputTextColor: Color.lerp(inputTextColor, other.inputTextColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      errorBackgroundColor:
          Color.lerp(errorBackgroundColor, other.errorBackgroundColor, t)!,
    );
  }
}
