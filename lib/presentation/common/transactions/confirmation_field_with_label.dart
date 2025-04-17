import 'package:flutter/material.dart';

class ConfirmationFieldWithLabel extends StatelessWidget {
  final String label;
  final String? value;
  final bool loading;

  const ConfirmationFieldWithLabel({
    super.key,
    required this.label,
    this.value,
    this.loading = false,
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
          child: SelectableText(label),
        ),
        DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyLarge ?? const TextStyle(),
          child: SelectableText(loading || value == null ? '' : value!),
        ),
      ],
    );
  }
}
