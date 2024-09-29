import 'package:flutter/material.dart';

class HorizonDropdownMenu<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final String? label;
  final TextEditingController? controller;
  final T? selectedValue;
  final Icon? icon;
  final double? borderRadius;
  final bool enabled;

  const HorizonDropdownMenu({
    super.key,
    required this.items,
    required this.onChanged,
    this.label,
    this.controller,
    this.selectedValue,
    this.icon,
    this.borderRadius,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        enabled: enabled,
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.never,
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
          onChanged: enabled ? onChanged : null,
          items: items,
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
          icon: icon,
        ),
      ),
    );
  }

  HorizonDropdownMenu<T> copyWith({bool? enabled}) {
    return HorizonDropdownMenu<T>(
      items: items,
      onChanged: onChanged,
      label: label,
      controller: controller,
      selectedValue: selectedValue,
      icon: icon,
      borderRadius: borderRadius,
      enabled: enabled ?? this.enabled,
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
