import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:flutter/services.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/common/fee_estimation_v2.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import './open_order_form_bloc.dart';

class OpenOrderForm extends StatefulWidget {
  final String? submissionError;

  const OpenOrderForm({super.key, this.submissionError});

  @override
  State<OpenOrderForm> createState() => _OpenOrderForm();
}

class _OpenOrderForm extends State<OpenOrderForm> {
  late TextEditingController _giveQuantityController;
  late TextEditingController _getQuantityController;
  late TextEditingController _giveAssetController;
  late TextEditingController _getAssetController;

  late FocusNode _giveQuantityFocusNode;
  late FocusNode _getQuantityFocusNode;
  late FocusNode _getAssetFocusNode;

  @override
  void initState() {
    super.initState();
    _giveAssetController = TextEditingController();
    _giveQuantityController = TextEditingController();
    _getQuantityController = TextEditingController();
    _getAssetController = TextEditingController();

    _giveQuantityFocusNode = FocusNode();
    _getQuantityFocusNode = FocusNode();
    _getAssetFocusNode = FocusNode();

    _giveQuantityFocusNode.addListener(() {
      if (!_giveQuantityFocusNode.hasFocus) {
        context.read<OpenOrderFormBloc>().add(GiveQuantityBlurred());
      }
    });

    _giveQuantityFocusNode.addListener(() {
      if (!_giveQuantityFocusNode.hasFocus) {
        context.read<OpenOrderFormBloc>().add(GiveQuantityBlurred());
      }
    });

    _getQuantityFocusNode.addListener(() {
      if (!_getQuantityFocusNode.hasFocus) {
        context.read<OpenOrderFormBloc>().add(GetQuantityBlurred());
      }
    });

    _getAssetFocusNode.addListener(() {
      if (!_getAssetFocusNode.hasFocus) {
        context.read<OpenOrderFormBloc>().add(GetAssetBlurred());
      }
    });

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get the current state from the bloc and initialize the controllers
    final state = context.read<OpenOrderFormBloc>().state;
    _initializeControllersFromState(state);
  }

  void _initializeControllersFromState(FormStateModel state) {
    // Set controller values if they differ from the current state
    if (_giveAssetController.text != state.giveAsset.value) {
      _giveAssetController.text = state.giveAsset.value;
    }

    if (_giveQuantityController.text != state.giveQuantity.value) {
      _giveQuantityController.text = state.giveQuantity.value;
    }

    if (_getQuantityController.text != state.getQuantity.value) {
      _getQuantityController.text = state.getQuantity.value;
    }

    if (_getAssetController.text != state.getAsset.value) {
      _getAssetController.text = state.getAsset.value;
    }
  }

  @override
  void dispose() {
    _giveAssetController.dispose();
    _giveQuantityController.dispose();
    _getQuantityController.dispose();
    _getAssetController.dispose();

    _giveQuantityFocusNode.dispose();
    _getQuantityFocusNode.dispose();
    _getAssetFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OpenOrderFormBloc, FormStateModel>(
        listener: (context, state) {
      if (_giveAssetController.text != state.giveAsset.value) {
        _giveAssetController.text = state.giveAsset.value;
      }

      if (_giveQuantityController.text != state.giveQuantity.value) {
        _giveQuantityController.text = state.giveQuantity.value;
      }
      if (_getQuantityController.text != state.getQuantity.value) {
        _getQuantityController.text = state.getQuantity.value;
      }

      if (_getAssetController.text != state.getAsset.value) {
        _getAssetController.text = state.getAsset.value;
      }

      if (state.submissionStatus.isSuccess) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('Dispenser Created Successfully')));
      } else if (state.submissionStatus.isFailure) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text(state.errorMessage ?? 'Submission Failed')));
      }
    }, builder: (context, state) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(2.0, 0.0, 0.0, 16.0),
              child: Text("Sell",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Row(
              children: [
                Expanded(
                    child: GiveQuantityInputField(
                        focusNode: _giveQuantityFocusNode,
                        controller: _giveQuantityController)),
                const SizedBox(width: 16),
                Expanded(
                    child: GiveAssetInputField(
                  controller: _giveAssetController,
                )),
              ],
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.fromLTRB(2.0, 0.0, 0.0, 16.0),
              child: Text("Buy",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Row(
              children: [
                Expanded(
                    child: GetQuantityInputField(
                  focusNode: _getQuantityFocusNode,
                  controller: _getQuantityController,
                )),
                const SizedBox(width: 16),
                Expanded(
                    child: GetAssetInputField(
                        controller: _getAssetController,
                        focusNode: _getAssetFocusNode))
              ],
            ),
            const SizedBox(height: 17),
            // Price and Lock Ratio Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price Label
                const Padding(
                  padding: EdgeInsets.fromLTRB(2.0, 8.0, 0.0, 16.0),
                  child: Text("Price",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                // Lock Ratio Toggle
                LockRatioToggle(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                children: [
                  Expanded(
                    child: Price(
                      giveQuantity: state.giveQuantity.isValid
                          ? double.tryParse(state.giveQuantity.value)
                          : null,
                      getQuantity: state.getQuantity.isValid
                          ? double.tryParse(state.getQuantity.value)
                          : null,
                      giveAsset: state.giveAsset.value,
                      getAsset: state.getAssetValidationStatus is Success
                          ? state.getAsset.value
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const HorizonUI.HorizonDivider(),
            FeeSelectionV2(
              value: state.feeOption,
              feeEstimates: switch (state.feeEstimates) {
                Success(data: var feeEstimates) =>
                  FeeEstimateSuccess(feeEstimates: feeEstimates),
                _ => FeeEstimateLoading()
              },
              onFieldSubmitted: () {},
              onSelected: (feeOption) {
                context
                    .read<OpenOrderFormBloc>()
                    .add(FeeOptionChanged(feeOption));
              },
              layout: MediaQuery.of(context).size.width > 768
                  ? FeeSelectionLayout.row
                  : FeeSelectionLayout.column,
            ),
            const HorizonUI.HorizonDivider(),
            if (state.submissionStatus.isFailure)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SelectableText(
                  state.errorMessage ?? "Submit failure",
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HorizonUI.HorizonCancelButton(
                  onPressed: () {
                    context.read<OpenOrderFormBloc>().add(FormCancelled());
                  },
                  buttonText: 'CANCEL',
                ),
                HorizonUI.HorizonContinueButton(
                  loading: state.submissionStatus.isInProgress,
                  onPressed: state.submissionStatus.isInProgress
                      ? () {}
                      : () {
                          context
                              .read<OpenOrderFormBloc>()
                              .add(FormSubmitted());
                        },
                  buttonText: 'CONTINUE',
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class GiveAssetInputField extends StatelessWidget {
  final TextEditingController controller;

  GiveAssetInputField({
    Key? key,
    required this.controller,
  }) : super(key: key);

  Future<List<Balance>> _fetchSuggestions(
      BuildContext context, String pattern) async {
    final bloc = context.read<OpenOrderFormBloc>();
    final currentState = bloc.state;

    if (currentState.giveAssets is Success<List<Balance>>) {
      final giveAssets =
          (currentState.giveAssets as Success<List<Balance>>).data;

      return giveAssets
          .where((element) =>
              element.asset.toLowerCase().contains(pattern.toLowerCase()))
          .toList();
    }

    final stream = bloc.stream;

    final successState = await stream.firstWhere(
      (state) =>
          state.giveAssets is Success<List<Balance>> ||
          state.giveAssets is Failure,
    );

    if (successState.giveAssets is Success<List<Balance>>) {
      final giveAssets =
          (successState.giveAssets as Success<List<Balance>>).data;

      return giveAssets
          .where((element) =>
              element.asset.toLowerCase().contains(pattern.toLowerCase()))
          .toList();
    } else {
      throw Exception('Failed to load assets');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpenOrderFormBloc, FormStateModel>(
      builder: (context, state) {
        final showError = !state.giveAsset.isPure && state.giveAsset.isNotValid;

        final error_ = switch (state.giveAsset.error) {
          GiveAssetValidationError.required => "Required",
          _ => null
        };

        final assetValidationError = switch (state.giveAssetValidationStatus) {
          Failure() => "Asset not found",
          _ => null
        };

        final error = assetValidationError ?? error_;

        return Autocomplete<Balance>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Balance>.empty();
            }
            return _fetchSuggestions(context, textEditingValue.text);
          },
          displayStringForOption: (Balance balance) => balance.asset,
          onSelected: (Balance selectedAsset) {
            context
                .read<OpenOrderFormBloc>()
                .add(GiveAssetChanged(selectedAsset.asset));
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            // Add a listener to the provided focusNode
            focusNode.addListener(() {
              if (!focusNode.hasFocus) {
                context.read<OpenOrderFormBloc>().add(GiveAssetBlurred());
                // Handle blur event here
                // You can perform any additional actions here
              }
            });

            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              onFieldSubmitted: (String? value) {
                onFieldSubmitted();
              },
              style: DefaultTextStyle.of(context).style,
              decoration: InputDecoration(
                labelText: "Give Asset",
                errorText: showError ? error : null,
                helperText: showError ? null : ' ',
                suffixIcon: switch (state.giveAssetValidationStatus) {
                  Loading() => Container(
                      height: 10,
                      width: 10,
                      margin: const EdgeInsets.all(12.0),
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  Success() => const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 20, // Adjust size as needed
                    ),
                  _ => const SizedBox.shrink(),
                },
              ),
            );
          },
        );
      },
    );
  }
}

class GetAssetInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const GetAssetInputField(
      {super.key, required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpenOrderFormBloc, FormStateModel>(
      // buildWhen: (previous, current) =>
      //     previous.getAsset != current.getAsset ||
      //     previous.getAssetValidationStatus != current.getAssetValidationStatus,
      builder: (context, state) {
        final hasError =
            (!state.getAsset.isPure && state.getAsset.isNotValid) ||
                state.getAssetValidationStatus is Failure;

        final error = switch (state.getAsset.error) {
          GetAssetValidationError.required => "Required",
          _ when state.getAssetValidationStatus is Failure => "Asset not found",
          _ => null
        };

        return TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (value) =>
              context.read<OpenOrderFormBloc>().add(GetAssetChanged(value)),
          decoration: InputDecoration(
              labelText: 'Get Asset',
              errorText: hasError ? error : null,
              helperText: hasError ? null : ' ',
              suffixIcon: switch (state.getAssetValidationStatus) {
                Loading() => Container(
                    height: 10,
                    width: 10,
                    margin: const EdgeInsets.all(12.0),
                    child: const CircularProgressIndicator(strokeWidth: 2)),
                Success() => const Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 20, // Adjust size as needed
                  ),
                _ => const SizedBox.shrink()
              }),
        );
      },
    );
  }
}

class GiveQuantityInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const GiveQuantityInputField(
      {super.key, required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpenOrderFormBloc, FormStateModel>(
      buildWhen: (previous, current) =>
          previous.giveQuantity != current.giveQuantity ||
          previous.giveAsset != current.giveAsset,
      builder: (context, state) {
        final isDivisible = state.giveQuantity.isDivisible; //
        // final isAssetSelected = state.giveAsset.value.isNotEmpty;
        final showError = !state.giveQuantity.isPure &&
            state.giveQuantity.isNotValid &&
            !focusNode.hasFocus;

        final errorMessage = switch (state.giveQuantity.error) {
          GiveQuantityValidationError.exceedsBalance =>
            'Quantity exceeds available balance',
          GiveQuantityValidationError.invalid =>
            isDivisible ? "invalid" : "Asset isn't divisible",
          GiveQuantityValidationError.required => "Required",
          _ => "none"
        };

        return TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (value) =>
              context.read<OpenOrderFormBloc>().add(GiveQuantityChanged(value)),
          decoration: InputDecoration(
            labelText: 'Give Quantity',
            errorText: showError ? errorMessage : null,
            helperText: showError ? null : ' ',
          ),
          keyboardType: const TextInputType.numberWithOptions(
              decimal: true, signed: false),
          inputFormatters: [DecimalTextInputFormatter(decimalRange: 8)],
          // enabled: isAssetSelected,
        );
      },
    );
  }
}

class GetQuantityInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const GetQuantityInputField(
      {super.key, required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpenOrderFormBloc, FormStateModel>(
      // buildWhen: (previous, current) =>
      //     previous.getQuantity != current.getQuantity ||
      //     previous.getAsset != previous.getAsset,
      builder: (context, state) {
        final isDivisible = state.getQuantity.isDivisible; //
        final showError = !state.getQuantity.isPure &&
            state.getQuantity.isNotValid &&
            !focusNode.hasFocus;

        final error = switch (state.getQuantity.error) {
          GetQuantityValidationError.invalid =>
            isDivisible ? "invalid" : "Asset isn't divisible",
          GetQuantityValidationError.required => "Required",
          _ => null
        };

        return TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (value) =>
              context.read<OpenOrderFormBloc>().add(GetQuantityChanged(value)),
          decoration: InputDecoration(
            labelText: 'Get Quantity',
            errorText: showError ? error : null,
            helperText: showError ? null : ' ',
            // errorText: state.quantity.invalid ? 'Invalid quantity' : null,
          ),
          keyboardType: const TextInputType.numberWithOptions(
              decimal: true, signed: false),
          inputFormatters: [DecimalTextInputFormatter(decimalRange: 8)],
        );
      },
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only allow digits and at most one decimal point
    final RegExp regExp = RegExp(r'^\d*\.?\d*$');
    if (!regExp.hasMatch(newValue.text)) {
      return oldValue;
    }

    String newText = newValue.text;
    TextSelection newSelection = newValue.selection;

    // Check if the new value has more than one decimal point
    if (newText.split('.').length > 2) {
      return oldValue; // Return the old value if there's more than one decimal point
    }

    if (newText.contains('.')) {
      String decimalPart = newText.substring(newText.indexOf('.') + 1);
      if (decimalPart.length > decimalRange) {
        newText = newText.substring(0, newText.indexOf('.') + decimalRange + 1);
        newSelection = TextSelection.collapsed(offset: newText.length);
      }
    }

    return TextEditingValue(
      text: newText,
      selection: newSelection,
    );
  }
}

class Price extends StatelessWidget {
  final double? giveQuantity;
  final double? getQuantity;
  final String? giveAsset;
  final String? getAsset;

  const Price(
      {super.key,
      this.giveQuantity,
      this.getQuantity,
      this.giveAsset,
      this.getAsset});
  @override
  Widget build(BuildContext context) {
    if (giveQuantity == null ||
        getQuantity == null ||
        giveAsset == null ||
        getAsset == null) {
      return const Text('-');
    }

    // Convert to Decimal for precise calculation and constrain to 8 decimal places
    final giveDecimal = Decimal.parse(giveQuantity!.toString());
    final getDecimal = Decimal.parse(getQuantity!.toString());
    final price =
        (giveDecimal / getDecimal).toDecimal(scaleOnInfinitePrecision: 8);

    return Text('$price ${giveAsset!}/${getAsset!}');
  }
}

class LockRatioToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpenOrderFormBloc, FormStateModel>(
      builder: (context, state) {
        return Row(
          children: [
            Text('Lock Price'),
            Switch(
              value: state.lockRatio,
              onChanged: (value) {
                context.read<OpenOrderFormBloc>().add(LockRatioChanged(value));
              },
            ),
          ],
        );
      },
    );
  }
}
