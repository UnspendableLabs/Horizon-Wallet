import 'package:flutter/material.dart';

class ConfirmationFieldWithLabel extends StatelessWidget {
  final Widget label;
  final Widget value;

  const ConfirmationFieldWithLabel({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextStyle(
          style:
              Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 14) ??
                  const TextStyle(),
          child: label,
        ),
        DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyLarge ?? const TextStyle(),
          child: value,
        ),
      ],
    );
  }
}
