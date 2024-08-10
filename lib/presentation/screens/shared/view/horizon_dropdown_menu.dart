import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';

class HorizonDropdownMenu extends StatelessWidget {
  final bool isDarkMode;
  final List<DropdownMenuItem<String>> items;
  final Function(String?) onChanged;
  final String? label;
  final TextEditingController? controller;
  final String? selectedValue;

  const HorizonDropdownMenu({
    super.key,
    required this.isDarkMode,
    required this.items,
    required this.onChanged,
    this.label,
    this.controller,
    this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    final dropdownBackgroundColor = isDarkMode ? darkThemeInputColor : lightThemeInputColor;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDarkMode ? darkThemeInputLabelColor : lightThemeInputLabelColor),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: dropdownBackgroundColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Adjust padding here
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedValue ?? items.first.value,
          onChanged: onChanged,
          dropdownColor: dropdownBackgroundColor,
          items: items,
        ),
      ),
    );
  }
}

DropdownMenuItem<String> buildDropdownMenuItem(String value, String description) {
  return DropdownMenuItem<String>(
    value: value,
    child: MouseRegion(
      onEnter: (_) {},
      onExit: (_) {},
      onHover: (_) {},
      child: Text(description, style: const TextStyle(fontWeight: FontWeight.normal)),
    ),
  );
}
