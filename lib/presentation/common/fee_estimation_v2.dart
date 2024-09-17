import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';

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

sealed class FeeOption {
  String get label;

  String toString() => switch (this) {
        Fast() => 'Fast()',
        Medium() => 'Medium()',
        Slow() => 'Slow()',
        Custom(fee: var fee) => 'Custom(fee: $fee)',
      };

  String toInputValue() => switch (this) {
        Fast() => 'fast',
        Medium() => 'medium',
        Slow() => 'slow',
        Custom() => 'custom',
      };

  static FeeOption fromString(String value, {int? customFee}) =>
      switch (value) {
        'fast' => Fast(),
        'medium' => Medium(),
        'slow' => Slow(),
        'custom' => Custom(customFee ?? 0),
        _ => Medium(),
      };
}

class Fast extends FeeOption {
  @override
  String get label => 'Fast';
}

class Medium extends FeeOption {
  @override
  String get label => 'Medium';
}

class Slow extends FeeOption {
  @override
  String get label => 'Slow';
}

class Custom extends FeeOption {
  final int fee;
  Custom(this.fee);

  @override
  String get label => 'Custom';
}

class FeeSelectionV2 extends StatefulWidget {
  final FeeEstimateState feeEstimates;
  final FeeSelectionLayout layout;
  final Function(FeeOption) onSelected;
  const FeeSelectionV2({
    Key? key,
    required this.feeEstimates,
    required this.layout,
    required this.onSelected,
  }) : super(key: key);

  @override
  _FeeSelectionV2State createState() => _FeeSelectionV2State();
}

class _FeeSelectionV2State extends State<FeeSelectionV2> {
  FeeOption _selectedFeeOption = Medium();
  TextEditingController _customFeeController = TextEditingController();

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
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: _buildDropdown(),
        ),
        SizedBox(height: 16),
        _buildCustomInput(),
      ],
    );
  }

  Widget _buildDropdown() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDarkMode ? darkThemeInputColor : lightThemeInputColor;

    return DropdownButtonFormField<String>(
      value: _selectedFeeOption.toInputValue(),
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      dropdownColor: fillColor,
      items: [
        DropdownMenuItem(value: 'fast', child: _buildDropdownItem(Fast())),
        DropdownMenuItem(value: 'medium', child: _buildDropdownItem(Medium())),
        DropdownMenuItem(value: 'slow', child: _buildDropdownItem(Slow())),
        DropdownMenuItem(value: 'custom', child: Text(Custom(0).label)),
      ],
      onChanged: (String? value) {
        if (value != null) {
          final newOption = FeeOption.fromString(value,
              customFee: _selectedFeeOption is Custom
                  ? (_selectedFeeOption as Custom).fee
                  : null);
          setState(() {
            _selectedFeeOption = newOption;
          });
          widget.onSelected(newOption);
        }
      },
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
        SizedBox(width: 16),
        if (widget.feeEstimates is FeeEstimateSuccess)
          Text(
            _getFeeEstimate(option,
                (widget.feeEstimates as FeeEstimateSuccess).feeEstimates),
            style: TextStyle(
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  Widget _buildCustomInput() {
    return Visibility(
      visible: _selectedFeeOption is Custom,
      maintainState: true,
      maintainAnimation: true,
      maintainSize: false,
      child: TextField(
        controller: _customFeeController,
        decoration: InputDecoration(
          labelText: 'Custom fee (sats/vbyte)',
          hintText: 'Enter custom fee rate',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (_selectedFeeOption is Custom) {
            final fee = int.tryParse(value) ?? 0;
            final newOption = Custom(fee);
            setState(() {
              _selectedFeeOption = newOption;
            });
            widget.onSelected(newOption);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _customFeeController.dispose();
    super.dispose();
  }
}
