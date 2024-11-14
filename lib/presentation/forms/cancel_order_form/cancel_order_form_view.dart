import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:flutter/services.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/common/fee_estimation_v2.dart';

import './cancel_order_form_bloc.dart';

class CancelOrderForm extends StatefulWidget {
  final String? submissionError;

  const CancelOrderForm({super.key, this.submissionError});

  @override
  State<CancelOrderForm> createState() => _CancelOrderForm();
}

class _CancelOrderForm extends State<CancelOrderForm> {
  late TextEditingController _offerHashController;

  @override
  void initState() {
    super.initState();
    _offerHashController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get the current state from the bloc and initialize the controllers
    final state = context.read<CancelOrderFormBloc>().state;
    _initializeControllersFromState(state);
  }

  void _initializeControllersFromState(FormStateModel state) {
    if (_offerHashController.text != state.offerHash.value) {
      _offerHashController.text = state.offerHash.value;
    }
  }

  @override
  void dispose() {
    _offerHashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CancelOrderFormBloc, FormStateModel>(
        listener: (context, state) {
      if (_offerHashController.text != state.offerHash.value) {
        _offerHashController.text = state.offerHash.value;
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
            OfferHashInputField(controller: _offerHashController),
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
                    .read<CancelOrderFormBloc>()
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
                    context.read<CancelOrderFormBloc>().add(FormCancelled());
                  },
                  buttonText: 'CANCEL',
                ),
                HorizonUI.HorizonContinueButton(
                  loading: state.submissionStatus.isInProgress,
                  onPressed: state.submissionStatus.isInProgress
                      ? () {}
                      : () {
                          context
                              .read<CancelOrderFormBloc>()
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

class OfferHashInputField extends StatelessWidget {
  TextEditingController controller;

  OfferHashInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CancelOrderFormBloc, FormStateModel>(
      // buildWhen: (previous, current) =>
      //     previous.offerHash != current.offerHash ||
      //     previous.offerHashValidationStatus != current.offerHashValidationStatus,
      builder: (context, state) {
        final hasError = !state.offerHash.isPure && state.offerHash.isNotValid;

        final error = switch (state.offerHash.error) {
          OfferHashValidationError.required => "Required",
          _ => null
        };

        return TextField(
            controller: controller,
            onChanged: (value) => context
                .read<CancelOrderFormBloc>()
                .add(OfferHashChanged(value)),
            decoration: InputDecoration(
              labelText: 'Offer Hash',
              errorText: hasError ? error : null,
              helperText: hasError ? null : ' ',
              // suffixIcon: switch (state.offerHashValidationStatus) {
              //   Loading() => Container(
              //       height: 10,
              //       width: 10,
              //       margin: const EdgeInsets.all(12.0),
              //       child: const CircularProgressIndicator(strokeWidth: 2)),
              //   Success() => const Icon(
              //       Icons.check,
              //       color: Colors.green,
              //       size: 20, // Adjust size as needed
              //     ),
              //   _ => const SizedBox.shrink()
              // }),
            ));
      },
    );
  }
}
