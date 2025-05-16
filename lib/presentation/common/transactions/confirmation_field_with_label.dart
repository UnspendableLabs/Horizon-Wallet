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
              Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ) ??
                  const TextStyle(),
          child: SelectableText(label),
        ),
        const SizedBox(
          height: 4,
        ),
        DefaultTextStyle(
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700
          ) ?? const TextStyle(),
          child: SelectableText(loading || value == null ? '' : value!),
        ),
        const SizedBox(
          height: 12,
        )
      ],
    );
  }
}
