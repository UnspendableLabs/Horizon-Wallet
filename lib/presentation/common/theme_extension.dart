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
    inputBackground: grey1,
    inputBackgroundEmpty: offWhite,
    inputBorderColor: transparentBlack8,
    inputTextColor: Colors.black,
    errorColor: red1,
    errorBackgroundColor: transparentRed16,
  );

  static const dark = CustomThemeExtension(
    inputBackground: grey5,
    inputBackgroundEmpty: offBlack,
    inputBorderColor: transparentWhite8,
    inputTextColor: Colors.white,
    errorColor: red1,
    errorBackgroundColor: transparentRed2,
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
