import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/common/transactions/input_loading_scaffold.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

class GradientQuantityInput extends StatefulWidget {
  final MultiAddressBalance? balance;
  final MultiAddressBalanceEntry? selectedBalanceEntry;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final bool enabled;
  final String? Function(String?)? validator;
  final bool? showMaxButton;

  const GradientQuantityInput({
    super.key,
    required this.balance,
    this.selectedBalanceEntry,
    required this.controller,
    this.onChanged,
    this.enabled = true,
    this.validator,
    this.showMaxButton = false,
  });

  @override
  State<GradientQuantityInput> createState() => _GradientQuantityInputState();
}

class _GradientQuantityInputState extends State<GradientQuantityInput> {
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(GradientQuantityInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        _hasText != widget.controller.text.isNotEmpty) {
      _hasText = widget.controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _handleMaxPressed() {
    if (widget.selectedBalanceEntry != null) {
      widget.controller.text = quantityRemoveTrailingZeros(
          widget.selectedBalanceEntry!.quantityNormalized);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.balance == null) {
      return const InputLoadingScaffold(height: 185);
    }

    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    final isDivisible = widget.balance?.assetInfo.divisible == true;
    final isDarkMode = theme.brightness == Brightness.dark;
    final isInputEnabled =
        widget.enabled && widget.selectedBalanceEntry != null;

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

    return FormField<String>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.validator,
      initialValue: widget.controller.text,
      builder: (FormFieldState<String> field) {
        final hasError = field.hasError;

        widget.controller.addListener(() {
          field.didChange(widget.controller.text);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MouseRegion(
              cursor: isInputEnabled
                  ? SystemMouseCursors.text
                  : SystemMouseCursors.basic,
              child: Container(
                height: 185,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: _hasText
                      ? customTheme.inputBackground
                      : customTheme.inputBackgroundEmpty,
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: hasError
                            ? Border.all(
                                color: customTheme.errorColor, width: 1)
                            : _focusNode.hasFocus
                                ? const GradientBoxBorder(width: 1)
                                : Border.all(
                                    color: customTheme.inputBorderColor),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: TextField(
                              enabled: isInputEnabled,
                              controller: widget.controller,
                              focusNode: _focusNode,
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                              style: const TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.w400,
                                color: Colors.transparent,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: isDivisible ? "0.00" : "0",
                                hintStyle: TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.w400,
                                  color: theme.hintColor,
                                ),
                                isCollapsed: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 0,
                                ),
                                alignLabelWithHint: true,
                              ),
                              expands: true,
                              maxLines: null,
                              minLines: null,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: isDivisible,
                                signed: false,
                              ),
                              inputFormatters: [
                                isDivisible
                                    ? DecimalTextInputFormatter(decimalRange: 8)
                                    : FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                field.didChange(value);
                                if (widget.onChanged != null) {
                                  widget.onChanged!(value);
                                }
                              },
                            ),
                          ),
                          Center(
                            child: ShaderMask(
                              shaderCallback: (bounds) {
                                return textGradient.createShader(bounds);
                              },
                              child: Text(
                                widget.controller.text.isEmpty
                                    ? ''
                                    : widget.controller.text,
                                style: const TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.w400,
                                  color: Colors
                                      .white, // This color will be replaced by gradient
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.selectedBalanceEntry != null &&
                        widget.showMaxButton == true)
                      Positioned(
                        right: 14,
                        bottom: 12,
                        child: GestureDetector(
                          onTap: isInputEnabled ? _handleMaxPressed : null,
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: transparentYellow8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Center(
                              child: Text(
                                'Max',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: yellow1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (hasError) ...[
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  field.errorText ?? '',
                  style: TextStyle(
                    color: customTheme.errorColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
