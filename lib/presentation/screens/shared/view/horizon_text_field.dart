import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';

class HorizonTextField extends StatelessWidget {
  final String? label;
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
    this.label,
    this.hint,
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
          labelText: label,
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

class HorizonTextFormField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Widget? suffix;
  final void Function(String)? onChanged;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final bool? obscureText;
  final bool? enableSuggestions;
  final bool? autocorrect;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final String? initialValue;

  const HorizonTextFormField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.suffix,
    this.onChanged,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.validator,
    this.obscureText,
    this.enableSuggestions,
    this.autocorrect,
    this.keyboardType,
    this.textCapitalization,
    this.inputFormatters,
    this.enabled,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    if (enabled == false) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

      final fillColor = isDarkMode
          ? dialogBackgroundColorDarkTheme
          : dialogBackgroundColorLightTheme;
      return InputDecorator(
        decoration: InputDecoration(
          fillColor: fillColor,
          labelText: label,
          suffix: suffix,
        ),
        child: obscureText == true
            ? Text(
                '•' * (controller?.text.length ?? 0),
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? mainTextWhite : mainTextBlack,
                ),
              )
            : SelectableText(
                controller?.text ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? mainTextWhite : mainTextBlack,
                ),
              ),
      );
    }

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      enabled: enabled ?? true,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      obscureText: obscureText ?? false,
      enableSuggestions: enableSuggestions ?? false,
      autocorrect: autocorrect ?? false,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        suffix: suffix,
      ),
      style: const TextStyle(
        fontSize: 16,
        // color: isDarkMode ? mainTextWhite : mainTextBlack,
      ),
    );
  }

  //  create a copy with updated properties
  HorizonTextFormField copyWith({bool? enabled}) {
    return HorizonTextFormField(
      label: label,
      hint: hint,
      controller: controller,
      focusNode: focusNode,
      suffix: suffix,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      obscureText: obscureText,
      enableSuggestions: enableSuggestions,
      autocorrect: autocorrect,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      enabled: enabled ?? this.enabled,
      initialValue: initialValue,
    );
  }
}
