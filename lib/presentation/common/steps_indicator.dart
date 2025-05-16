import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';

class StepsIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final double width;
  final Duration duration;

  const StepsIndicator({
    super.key,
    required this.progress,
    this.height = 8,
    this.width = 48,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: transparentWhite33,
      ),
      child: AnimatedFractionallySizedBox(
        duration: duration,
        curve: Curves.easeInOut,
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              colors: [
                pinkGradient1,
                purpleGradient1,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
