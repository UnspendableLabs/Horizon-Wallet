import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/common/fee_estimation_v2.dart';

import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
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

  @override
  void initState() {
    super.initState();
    _giveAssetController = TextEditingController();
    _giveQuantityController = TextEditingController();
    _getQuantityController = TextEditingController();
    _getAssetController = TextEditingController();
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
    // TODO: implement dispose
    _giveAssetController.dispose();
    _giveQuantityController.dispose();
    _getQuantityController.dispose();
    _getAssetController.dispose();
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
            Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 0.0, 0.0, 16.0),
              child: Text("Sell",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Row(
              children: [
                Expanded(
                    child: GiveQuantityInputField(
                        controller: _giveQuantityController)),
                const SizedBox(width: 16),
                Expanded(child: GiveAssetInputField()),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 0.0, 0.0, 16.0),
              child: Text("Buy",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Row(
              children: [
                Expanded(
                    child: GetQuantityInputField(
                  controller: _getQuantityController,
                )),
                const SizedBox(width: 16),
                Expanded(
                    child: GetAssetInputField(controller: _getAssetController))
              ],
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

              // TODO: replicate this functionality

              // state.feeState.maybeWhen(
              //   success: (feeEstimates) =>
              //       FeeEstimateSuccess(feeEstimates: feeEstimates),
              //   orElse: () => FeeEstimateLoading(),
              // ),
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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpenOrderFormBloc, FormStateModel>(
      // buildWhen: (previous, current) =>
      //     previous.giveAssets != current.giveAssets ||
      //     previous.giveAsset != current.giveAsset,
      builder: (context, state) {
        if (state.giveAssets is Loading) {
          return Center(child: CircularProgressIndicator());
        } else if (state.giveAssets is Success<List<Balance>>) {
          final giveAssets = (state.giveAssets as Success<List<Balance>>).data;
          final hasError =
              !state.giveAsset.isPure && state.giveAsset.error != null;
          final errorMessage = 'Please select an asset';

          return HorizonUI.HorizonDropdownMenu<String>(
            enabled: true,
            label: 'Give Asset',
            selectedValue:
                state.giveAsset.value.isNotEmpty ? state.giveAsset.value : null,
            onChanged: (selectedAsset) {
              if (selectedAsset != null) {
                context
                    .read<OpenOrderFormBloc>()
                    .add(GiveAssetChanged(selectedAsset));
              }
            },
            // selectedValue: state.giveAsset.value,
            items: giveAssets.map<DropdownMenuItem<String>>((balance) {
              return HorizonUI.buildDropdownMenuItem(
                  balance.asset, balance.asset);
            }).toList(),
            errorText: hasError ? errorMessage : null,
            helperText: hasError ? null : ' ',
          );
        } else if (state.giveAssets is Failure) {
          return Text('Failed to load assets',
              style: TextStyle(color: Colors.red));
        } else {
          return Text("not asked");
        }
      },
    );
  }
}

class GetAssetInputField extends StatelessWidget {
  TextEditingController controller;

  GetAssetInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpenOrderFormBloc, FormStateModel>(
      buildWhen: (previous, current) =>
          previous.getAsset != current.getAsset ||
          previous.getAssetValidationStatus != current.getAssetValidationStatus,
      builder: (context, state) {
        return TextField(
          controller: controller,
          onChanged: (value) =>
              context.read<OpenOrderFormBloc>().add(GetAssetChanged(value)),
          decoration: InputDecoration(
              labelText: 'Get Asset',
              helperText: " ",
              errorText: state.getAssetValidationStatus is Failure
                  ? 'Asset not found'
                  : null,
              suffixIcon: switch (state.getAssetValidationStatus) {
                Loading() => Container(
                    margin: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2)),
                Success() => const Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 20, // Adjust size as needed
                  ),
                _ => SizedBox.shrink()
              }),
        );
      },
    );
  }
}

class GiveQuantityInputField extends StatelessWidget {
  final TextEditingController controller;

  const GiveQuantityInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpenOrderFormBloc, FormStateModel>(
      // buildWhen: (previous, current) =>
      //     previous.giveQuantity != current.giveQuantity ||
      //     previous.giveAsset != current.giveAsset,
      builder: (context, state) {
        final isDivisible = state.giveQuantity.isDivisible; //
        final isAssetSelected = state.giveAsset.value.isNotEmpty;
        final hasError =
            !state.giveQuantity.isPure && state.giveQuantity.isNotValid;
        final errorMessage = state.giveQuantity.error ==
                GiveQuantityValidationError.exceedsBalance
            ? 'Quantity exceeds available balance'
            : 'Invalid quantity';

        return TextField(
          controller: controller,
          onChanged: (value) =>
              context.read<OpenOrderFormBloc>().add(GiveQuantityChanged(value)),
          decoration: InputDecoration(
            labelText: 'Give Quantity',
            errorText: hasError ? errorMessage : null,
            helperText: hasError ? null : ' ',
          ),
          keyboardType: isDivisible
              ? TextInputType.numberWithOptions(decimal: true)
              : TextInputType.number,
          enabled: isAssetSelected,
        );
      },
    );
  }
}

class GetQuantityInputField extends StatelessWidget {
  final TextEditingController controller;

  const GetQuantityInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpenOrderFormBloc, FormStateModel>(
      // buildWhen: (previous, current) =>
      //     previous.getQuantity != current.getQuantity ||
      //     previous.getAsset != previous.getAsset,
      builder: (context, state) {
        final isDivisible = state.getQuantity.isDivisible; //
        final isAssetSelected = state.getAsset.value.isNotEmpty;
        final hasError =
            !state.getQuantity.isPure && state.getQuantity.isNotValid;

        return TextField(
          controller: controller,
          onChanged: (value) =>
              context.read<OpenOrderFormBloc>().add(GetQuantityChanged(value)),
          decoration: InputDecoration(
            labelText: 'Get Quantity',
            errorText: hasError ? 'Invalid quantity' : null,
            helperText: hasError ? null : ' ',
            // errorText: state.quantity.invalid ? 'Invalid quantity' : null,
          ),
          keyboardType: isDivisible
              ? TextInputType.numberWithOptions(decimal: true)
              : TextInputType.number,
        );
      },
    );
  }
}
