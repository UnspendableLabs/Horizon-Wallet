import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';

class HorizonDropdownMenu<T> extends StatelessWidget {
  final bool isDarkMode;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final String? label;
  final TextEditingController? controller;
  final T? selectedValue;
  final Icon? icon;
  final double? borderRadius;

  const HorizonDropdownMenu({
    super.key,
    required this.isDarkMode,
    required this.items,
    required this.onChanged,
    this.label,
    this.controller,
    this.selectedValue,
    this.icon,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final dropdownBackgroundColor =
        isDarkMode ? darkThemeInputColor : lightThemeInputColor;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: isDarkMode
                ? darkThemeInputLabelColor
                : lightThemeInputLabelColor),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: dropdownBackgroundColor,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 12.0, vertical: 8.0), // Adjust padding here
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: selectedValue ?? items.first.value,
          onChanged: onChanged,
          dropdownColor: dropdownBackgroundColor,
          items: items,
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
          icon: icon,
        ),
      ),
    );
  }
}

DropdownMenuItem<String> buildDropdownMenuItem(
    String value, String description) {
  return DropdownMenuItem<String>(
    value: value,
    child: MouseRegion(
      onEnter: (_) {},
      onExit: (_) {},
      onHover: (_) {},
      child: Text(description,
          style: const TextStyle(fontWeight: FontWeight.normal)),
    ),
  );
}
