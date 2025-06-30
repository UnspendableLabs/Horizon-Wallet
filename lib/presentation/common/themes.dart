import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/theme_extension.dart';

ThemeData buildLightTheme() {
  final baseTextTheme = ThemeData.light().textTheme;
  const customTextTheme = TextTheme(
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Colors.black,
      fontFamily: 'Montserrat',
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      color: transparentBlack66,
      fontFamily: 'Montserrat',
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      color: Colors.black,
      fontFamily: 'Montserrat',
      fontWeight: FontWeight.w700,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      color: Colors.black,
      fontFamily: 'Montserrat',
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: Colors.black,
      fontFamily: 'Montserrat',
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      color: Colors.black,
      fontFamily: 'Montserrat',
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      color: transparentBlack66,
      fontFamily: 'Montserrat',
    ),
  );

  return ThemeData(
    fontFamily: 'Montserrat',
    brightness: Brightness.light,
    scaffoldBackgroundColor: offWhite,
    dialogTheme: DialogTheme(
      backgroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
    primaryTextTheme: baseTextTheme.apply(fontFamily: 'Montserrat'),
    textTheme: customTextTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.all(20),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'Montserrat',
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: const BorderSide(color: transparentBlack8),
        ),
        padding: const EdgeInsets.all(20),
        foregroundColor: offBlack,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: 'Montserrat',
        ),
        disabledBackgroundColor: const Color.fromRGBO(10, 10, 10, 0.16),
        disabledForegroundColor: Colors.white.withOpacity(0.5),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 8,
          fontWeight: FontWeight.w500,
          height: 1.2, // This gives us 9.6px line height (8 * 1.2 = 9.6)
          letterSpacing: 0,
        ),
        foregroundColor: transparentBlack33,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.fromLTRB(7, 11, 14, 11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: transparentBlack8,
          ),
        ),
      ),
    ),
    iconTheme: const IconThemeData(
      color: Colors.black,
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      textStyle: TextStyle(
        fontSize: 12,
        color: Colors.black,
        fontFamily: 'Montserrat',
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(grey1),
        surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        shadowColor: WidgetStatePropertyAll(Colors.transparent),
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      isDense: true,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: transparentBlack8,
        fontFamily: 'Montserrat',
      ),
      contentPadding: EdgeInsets.zero,
      outlineBorder: BorderSide(
        color: transparentBlack8,
        width: 1,
      ),
      border: InputBorder.none,
      hintStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: transparentBlack33,
        fontFamily: 'Montserrat',
      ),
    ),
    extensions: const {
      CustomThemeExtension.light,
    },
  );
}

ThemeData buildDarkTheme() {
  final baseTextTheme = ThemeData.dark().textTheme;
  const customTextTheme = TextTheme(
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: offWhite,
      fontFamily: 'Montserrat',
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      color: transparentWhite66,
      fontFamily: 'Montserrat',
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      color: Colors.white,
      fontFamily: 'Montserrat',
      fontWeight: FontWeight.w700,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      color: Colors.white,
      fontFamily: 'Montserrat',
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: offWhite,
      fontFamily: 'Montserrat',
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      color: Colors.white,
      fontFamily: 'Montserrat',
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      color: transparentWhite66,
      fontFamily: 'Montserrat',
    ),
  );

  return ThemeData(
    fontFamily: 'Montserrat',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: offBlack,
    dialogTheme: DialogTheme(
      backgroundColor: black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
    primaryTextTheme: baseTextTheme.apply(fontFamily: 'Montserrat'),
    textTheme: customTextTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.all(20),
        foregroundColor: Colors.black,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'Montserrat',
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: const BorderSide(color: transparentWhite8),
        ),
        padding: const EdgeInsets.all(20),
        foregroundColor: offWhite,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: 'Montserrat',
        ),
        disabledBackgroundColor: const Color.fromRGBO(254, 251, 249, 0.16),
        disabledForegroundColor: Colors.white.withOpacity(0.5),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 8,
          fontWeight: FontWeight.w500,
          height: 1.2, // This gives us 9.6px line height (8 * 1.2 = 9.6)
          letterSpacing: 0,
        ),
        foregroundColor: transparentWhite33,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: black,
        foregroundColor: white,
        padding: const EdgeInsets.fromLTRB(7, 11, 14, 11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: transparentWhite8,
          ),
        ),
      ),
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      textStyle: TextStyle(
        fontSize: 12,
        color: Colors.white,
        fontFamily: 'Montserrat',
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(grey5),
        surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        shadowColor: WidgetStatePropertyAll(Colors.transparent),
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: transparentWhite8,
        fontFamily: 'Montserrat',
      ),
      isDense: true,
      contentPadding: EdgeInsets.zero,
      outlineBorder: BorderSide(color: transparentWhite8, width: 1),
      border: InputBorder.none,
      hintStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: transparentWhite33,
        fontFamily: 'Montserrat',
      ),
    ),
    extensions: const {
      CustomThemeExtension.dark,
    },
  );
} 