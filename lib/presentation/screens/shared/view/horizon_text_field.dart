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
  final bool? enabled;

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
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    // the use of Expanded here requires this text field to be a child of a column, row,  or flex widget
    return Expanded(
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        obscureText: obscureText ?? false,
        enableSuggestions: enableSuggestions ?? false,
        autocorrect: autocorrect ?? false,
        enabled: enabled ?? true,
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

class HorizonTextFormField extends StatelessWidget {
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
  final bool? enabled;
  final Color? fillColor;
  final Color? textColor;

  const HorizonTextFormField({
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
    this.enabled,
    this.fillColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = InputDecoration(
      filled: true,
      fillColor: fillColor ??
          (isDarkMode ? darkThemeInputColor : lightThemeInputColor),
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
    );

    if (enabled == false) {
      return InputDecorator(
        decoration: decoration,
        child: obscureText == true
            ? Text(
                '•' * (controller?.text.length ?? 0),
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              )
            : SelectableText(
                controller?.text ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
      );
    }

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled ?? true,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      validator: validator,
      obscureText: obscureText ?? false,
      enableSuggestions: enableSuggestions ?? false,
      autocorrect: autocorrect ?? false,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      inputFormatters: inputFormatters,
      decoration: decoration,
      style: TextStyle(
        fontSize: 16,
        color: textColor,
      ),
    );
  }
}
