import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/common/transactions/input_loading_scaffold.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

/// A component for selecting transaction fee rates
class TransactionFeeInput extends StatefulWidget {
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
  State<TransactionFeeInput> createState() => _TransactionFeeInputState();
}

class _TransactionFeeInputState extends State<TransactionFeeInput> {
  bool _showCustomFeeInput = false;
  final TextEditingController _customFeeController = TextEditingController();

  @override
  void dispose() {
    _customFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    if (widget.feeEstimates == null) {
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
          const SizedBox(height: 12),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showCustomFeeInput = true;
                  if (widget.selectedFeeOption is! Custom) {
                    widget.onFeeOptionSelected(Custom(0));
                  }
                });
              },
              child: Container(
                height: 32,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: transparentPurple8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Custom Fee',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_showCustomFeeInput) ...[
            commonHeightSizedBox,
            Center(
              child: HorizonTextField(
                controller: _customFeeController,
                label: 'Custom fee (sat/vbyte)',
                inputFormatters: [
                  DecimalTextInputFormatter(decimalRange: 2),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a fee';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value != null && value.isNotEmpty) {
                    final fee = num.tryParse(value) ?? 0;
                    widget.onFeeOptionSelected(Custom(fee));
                  }
                },
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    setState(() {
                      _showCustomFeeInput = false;
                      _customFeeController.clear();
                      widget.onFeeOptionSelected(Medium());
                    });
                  },
                ),
              ),
            ),
          ],
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
    final isSelected =
        widget.selectedFeeOption.runtimeType == feeOption.runtimeType;
    final textTheme = Theme.of(context).textTheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onFeeOptionSelected(feeOption),
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
      ),
    );
  }

  String _getFeeEstimate(FeeOption option) {
    return switch (option) {
      Fast() => "${widget.feeEstimates!.fast} sat/vbyte",
      Medium() => "${widget.feeEstimates!.medium} sat/vbyte",
      Slow() => "${widget.feeEstimates!.slow} sat/vbyte",
      Custom() => "${_customFeeController.text} sat/vbyte",
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
