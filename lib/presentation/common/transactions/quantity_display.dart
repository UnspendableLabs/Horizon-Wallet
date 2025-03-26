import 'package:flutter/material.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';

class QuantityDisplay extends StatelessWidget {
  final String quantity;

  const QuantityDisplay({
    super.key,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final Gradient textGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: isDarkMode
          ? const [
              goldenGradient1,
              yellow1,
              goldenGradient2,
              goldenGradient3,
            ]
          : const [
              duskGradient2,
              duskGradient1,
            ],
      stops: isDarkMode ? const [0.0, 0.325, 0.65, 1.0] : const [0.0, 1.0],
    );

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            // padding: const EdgeInsets.symmetric(vertical: 10),
            child: SelectableText(
              "You're sending",
              style: theme.textTheme.labelSmall?.copyWith(fontSize: 14),
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) {
              return textGradient.createShader(bounds);
            },
            child: SelectableText(
              quantityRemoveTrailingZeros(quantity),
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w400,
                color: Colors.white, // This color will be replaced by gradient
              ),
            ),
          ),
        ],
      ),
    );
  }
}
