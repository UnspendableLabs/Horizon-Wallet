import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

class ExpirySelectorOption {
  final String label;
  final Duration duration;
  final bool isCustom;

  const ExpirySelectorOption({
    required this.label,
    required this.duration,
    this.isCustom = false,
  });
}

class ExpirySelector extends StatefulWidget {
  static const List<ExpirySelectorOption> defaultExpirySelectorOptions = [
    ExpirySelectorOption(
        label: "Never", duration: Duration.zero, isCustom: false),
    ExpirySelectorOption(
      label: "1 month",
      duration: Duration(days: 30),
      isCustom: false,
    ),
    ExpirySelectorOption(
      label: "1 year",
      duration: Duration(days: 365),
      isCustom: false,
    ),
    ExpirySelectorOption(
      label: "Custom",
      duration: Duration.zero,
      isCustom: true,
    ),
  ];

  final List<ExpirySelectorOption> options;
  final void Function(DateTime? date) onChange;

  const ExpirySelector({
    super.key,
    this.options = defaultExpirySelectorOptions,
    required this.onChange,
  });

  @override
  State<ExpirySelector> createState() => _ExpirySelectorState();
}

class _ExpirySelectorState extends State<ExpirySelector> {
  ExpirySelectorOption? _selectedOption = const ExpirySelectorOption(
    label: "Never",
    duration: Duration.zero,
    isCustom: false,
  );

  Future<void> _launchDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 100)),
    );

    if (picked != null) {
      setState(() {
        _selectedOption = widget.options.firstWhere(
          (option) => option.isCustom,
        );
      });
      widget.onChange(picked);
    }
  }

  void _handleOptionPressed(ExpirySelectorOption option) async {
    DateTime? expiryDate;

    if (option.isCustom) {
      await _launchDatePicker();
      return;
    }

    if (option.duration != Duration.zero) {
      expiryDate = DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .add(option.duration);
    }

    setState(() {
      _selectedOption = option;
    });

    widget.onChange(expiryDate);
  }

  String _getLabelText(ExpirySelectorOption option) {
    if (option.isCustom && _selectedOption == option) {
      final date = DateTime.now().add(option.duration);
      return DateFormat('dd-MM-yyyy').format(date);
    }
    return option.label;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(
            "Expiry",
            style: theme.textTheme.titleSmall,
          )),
          ...widget.options.asMap().entries.map((entry) {
            final option = entry.value;
            final index = entry.key;
            final isSelected = _selectedOption == option;
            return [
              SizedBox(
                height: 24,
                child: TextButton(
                  onPressed: () => _handleOptionPressed(option),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7.64, vertical: 0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor:
                        isSelected ? transparentWhite33 : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.64),
                      side: BorderSide(
                        color: isSelected
                            ? transparentWhite33
                            : transparentWhite16,
                        width: 0.76,
                      ),
                    ),
                  ),
                  child: Text(
                    _getLabelText(option),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
              if (index < widget.options.length - 1) commonWidthSizedBox,
            ];
          }).expand((widgets) => widgets),
        ],
      ),
    );
  }
}
