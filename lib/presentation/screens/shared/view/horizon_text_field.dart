import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';

class HorizonTextField extends StatelessWidget {
  final bool isDarkMode;
  final String? label;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final void Function()? onEditingComplete;
  final bool? obscureText;
  final bool? enableSuggestions;
  final bool? autocorrect;

  const HorizonTextField({
    super.key,
    required this.isDarkMode,
    this.label,
    this.hint,
    this.floatingLabelBehavior,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onEditingComplete,
    this.obscureText,
    this.enableSuggestions,
    this.autocorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        obscureText: obscureText ?? false,
        enableSuggestions: enableSuggestions ?? false,
        autocorrect: autocorrect ?? false,
        decoration: InputDecoration(
          filled: true,
          fillColor: isDarkMode ? darkThemeInputColor : lightThemeInputColor,
          labelText: label,
          floatingLabelBehavior:
              floatingLabelBehavior ?? FloatingLabelBehavior.never,
          labelStyle: TextStyle(
              fontWeight: FontWeight.normal,
              color: isDarkMode
                  ? darkThemeInputLabelColor
                  : lightThemeInputLabelColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

class HorizoneTextFormField extends StatelessWidget {
  final bool isDarkMode;
  final String? label;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Widget? suffix;
  final void Function(String)? onChanged;
  final void Function()? onEditingComplete;
  final String? Function(String?)? validator;
  final bool? obscureText;
  final bool? enableSuggestions;
  final bool? autocorrect;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  const HorizoneTextFormField({
    super.key,
    required this.isDarkMode,
    this.label,
    this.hint,
    this.floatingLabelBehavior,
    this.controller,
    this.focusNode,
    this.suffix,
    this.onChanged,
    this.onEditingComplete,
    this.validator,
    this.obscureText,
    this.enableSuggestions,
    this.autocorrect,
    this.keyboardType,
    this.textCapitalization,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      validator: validator,
      obscureText: obscureText ?? false,
      enableSuggestions: enableSuggestions ?? false,
      autocorrect: autocorrect ?? false,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        filled: true,
        fillColor: isDarkMode ? darkThemeInputColor : lightThemeInputColor,
        labelText: label,
        floatingLabelBehavior:
            floatingLabelBehavior ?? FloatingLabelBehavior.never,
        labelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            color: isDarkMode
                ? darkThemeInputLabelColor
                : lightThemeInputLabelColor),
        suffix: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }
}
