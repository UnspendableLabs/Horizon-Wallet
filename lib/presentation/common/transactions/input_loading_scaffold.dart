import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';

class InputLoadingScaffold extends StatelessWidget {
  final double height;

  const InputLoadingScaffold({
    super.key,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.outlineBorder?.color ??
              transparentBlack8,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
