import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/common/transactions/input_loading_scaffold.dart';

/// A component for selecting transaction fee rates
class TransactionFeeInput extends StatelessWidget {
  /// Fee estimates for different priority levels
  final FeeEstimates? feeEstimates;

  /// Currently selected fee option
  final FeeOption? selectedFeeOption;

  /// Callback when a fee option is selected
  final Function(FeeOption) onFeeOptionSelected;

  const TransactionFeeInput({
    super.key,
    required this.feeEstimates,
    required this.selectedFeeOption,
    required this.onFeeOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    if (feeEstimates == null) {
      return const InputLoadingScaffold();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: customTheme.inputBorderColor,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fee Selection',
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFeeButton(
                  label: 'Low',
                  feeOption: Slow(),
                  context: context,
                  customTheme: customTheme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFeeButton(
                  label: 'Medium',
                  feeOption: Medium(),
                  context: context,
                  customTheme: customTheme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFeeButton(
                  label: 'High',
                  feeOption: Fast(),
                  context: context,
                  customTheme: customTheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeeButton({
    required String label,
    required FeeOption feeOption,
    required BuildContext context,
    required CustomThemeExtension customTheme,
  }) {
    final isSelected = selectedFeeOption.runtimeType == feeOption.runtimeType;
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => onFeeOptionSelected(feeOption),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? customTheme.inputBackground
              : customTheme.inputBackgroundEmpty,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? _buildGradientBorder(context)
              : Border.all(
                  color: customTheme.inputBorderColor,
                ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getFeeEstimate(feeOption),
              style: textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFeeEstimate(FeeOption option) {
    return switch (option) {
      Fast() => "${feeEstimates!.fast} sat/vbyte",
      Medium() => "${feeEstimates!.medium} sat/vbyte",
      Slow() => "${feeEstimates!.slow} sat/vbyte",
      Custom() => "",
    };
  }

  BoxBorder _buildGradientBorder(BuildContext context) {
    return const GradientBorder(
      gradient: LinearGradient(
        colors: [
          beige,
          warmBeige,
          softOrange,
          coral,
          violet,
          moderateBlue,
          softTurquoise,
          lightBeige,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      width: 1.5,
    );
  }
}

class GradientBorder extends BoxBorder {
  final Gradient gradient;
  final double width;

  const GradientBorder({
    required this.gradient,
    required this.width,
  });

  @override
  BorderSide get top => BorderSide(width: width);

  @override
  BorderSide get right => BorderSide(width: width);

  @override
  BorderSide get bottom => BorderSide(width: width);

  @override
  BorderSide get left => BorderSide(width: width);

  @override
  bool get isUniform => true;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    final RRect rrect = borderRadius != null
        ? borderRadius.toRRect(rect)
        : RRect.fromRectAndRadius(rect, const Radius.circular(0));

    canvas.drawRRect(rrect, paint);
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  ShapeBorder scale(double t) => GradientBorder(
        gradient: gradient,
        width: width * t,
      );
}
