import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

enum FeeSelectionLayout { row, column }

sealed class FeeEstimateState {}

class FeeEstimateInitial extends FeeEstimateState {}

class FeeEstimateLoading extends FeeEstimateState {}

class FeeEstimateSuccess extends FeeEstimateState {
  final FeeEstimates feeEstimates;
  FeeEstimateSuccess({required this.feeEstimates});
}

class FeeEstimateError extends FeeEstimateState {
  final String error;
  FeeEstimateError(this.error);
}

class FeeSelectionV2 extends StatefulWidget {
  final FeeOption value;
  final FeeEstimateState feeEstimates;
  final FeeSelectionLayout layout;
  final Function(FeeOption) onSelected;
  final Function() onFieldSubmitted;
  final bool enabled;

  const FeeSelectionV2({
    super.key,
    required this.feeEstimates,
    required this.layout,
    required this.onSelected,
    required this.value,
    required this.onFieldSubmitted,
    this.enabled = true,
  });

  @override
  _FeeSelectionV2State createState() => _FeeSelectionV2State();

  FeeSelectionV2 copyWith({bool? enabled}) {
    return FeeSelectionV2(
      feeEstimates: feeEstimates,
      layout: layout,
      onSelected: onSelected,
      value: value,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled ?? this.enabled,
    );
  }
}

class _FeeSelectionV2State extends State<FeeSelectionV2> {
  @override
  Widget build(BuildContext context) {
    return switch (widget.layout) {
      FeeSelectionLayout.row => _buildWideLayout(),
      FeeSelectionLayout.column => _buildNarrowLayout(),
    };
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildDropdown()),
        const SizedBox(width: 16),
        Expanded(child: _buildCustomInput()),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(),
        const SizedBox(height: 16),
        _buildCustomInput(),
      ],
    );
  }

  Widget _buildDropdown() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDarkMode ? darkThemeInputColor : lightThemeInputColor;

    return DropdownButtonFormField<String>(
      key: const Key("fee_dropdown"),
      value: widget.value.toInputValue(),
      decoration: InputDecoration(
        fillColor: fillColor,
        filled: true,
        labelText: 'Fee Selection',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        enabled: widget.enabled,
      ),
      dropdownColor: fillColor,
      items: [
        DropdownMenuItem(value: 'fast', child: _buildDropdownItem(Fast())),
        DropdownMenuItem(value: 'medium', child: _buildDropdownItem(Medium())),
        DropdownMenuItem(value: 'slow', child: _buildDropdownItem(Slow())),
        DropdownMenuItem(value: 'custom', child: Text(Custom(0).label)),
      ],
      onChanged: widget.enabled
          ? (String? value) {
              if (value != null) {
                final newOption = FeeOption.fromString(value,
                    customFee: widget.value is Custom
                        ? (widget.value as Custom).fee
                        : null);
                // setState(() {
                //   _selectedFeeOption = newOption;
                // });
                widget.onSelected(newOption);
              }
            }
          : null,
    );
  }

  String _getFeeEstimate(FeeOption option, FeeEstimates estimates) {
    return switch (option) {
      Fast() => "${estimates.fast} sat/vbyte",
      Medium() => "${estimates.medium} sat/vbyte",
      Slow() => "${estimates.slow} sat/vbyte",
      Custom() => "",
    };
  }

  Widget _buildDropdownItem(FeeOption option) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(option.label),
        const SizedBox(width: 16),
        if (widget.feeEstimates is FeeEstimateSuccess)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
            child: Text(
              _getFeeEstimate(option,
                  (widget.feeEstimates as FeeEstimateSuccess).feeEstimates),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildCustomInput() {
    return Visibility(
      visible: widget.value is Custom,
      maintainState: true,
      maintainAnimation: true,
      maintainSize: false,
      child: HorizonUI.HorizonTextFormField(
        label: 'Custom fee (sats/vbyte)',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        onChanged: widget.enabled
            ? (value) {
                if (widget.value is Custom) {
                  final fee = num.tryParse(value) ?? 0;
                  final newOption = Custom(fee);
                  widget.onSelected(newOption);
                }
              }
            : null,
        validator: (value) {
          if (widget.value is Custom) {
            if (value == null || value.isEmpty) {
              return 'Please enter a fee';
            }
          }
          return null;
        },
        onFieldSubmitted:
            widget.enabled ? (_) => widget.onFieldSubmitted() : null,
        enabled: widget.enabled,
      ),
    );
  }

  @override
  void dispose() {
    // _customFeeController.dispose();
    super.dispose();
  }
}
