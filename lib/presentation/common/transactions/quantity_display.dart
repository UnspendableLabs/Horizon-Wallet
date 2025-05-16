import 'package:flutter/material.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/theme_extension.dart';

class QuantityDisplay extends StatelessWidget {
  final String? quantity;
  final bool loading;

  const QuantityDisplay({
    super.key,
    this.quantity,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>();
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
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SelectableText(
              "You're sending",
              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          if (!loading && quantity != null)
            ShaderMask(
              shaderCallback: (bounds) {
                return textGradient.createShader(bounds);
              },
              child: SelectableText(
                quantityRemoveTrailingZeros(quantity!),
                style: customTheme?.number35Regular,
              ),
            ),
        ],
      ),
    );
  }
}
