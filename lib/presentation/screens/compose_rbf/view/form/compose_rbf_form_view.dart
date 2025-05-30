import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/fee_estimation_v2.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/domain/entities/remote_data.dart';

import "./compose_rbf_form_bloc.dart";

class OnSubmitSuccess {
  final String psbtHex;
  const OnSubmitSuccess({required this.psbtHex});
}

class ReplaceByFeeForm extends StatelessWidget {
  final String? submissionError;
  final void Function(MakeRBFResponse psbtHex, RBFData rbfData) onSubmitSuccess;
  final void Function() onCancel;

  const ReplaceByFeeForm(
      {super.key,
      required this.onCancel,
      this.submissionError,
      required this.onSubmitSuccess});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReplaceByFeeFormBloc, FormStateModel>(
        listener: (context, state) {
      if (state.submissionStatus.isSuccess) {
        onSubmitSuccess(state.rbfResponse!, successOrThrow(state.rbfData));
      }
    }, builder: (context, state) {
      return switch (state.rbfData) {
        Success(data: var data) => Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Transaction Hash:',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              SelectableText(
                state.txHash,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16.0),
              Text(
                'Fee:',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                "${data.tx.fee} sats",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16.0),
              Text(
                "Fee Rate:",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                "${(data.tx.fee / data.adjustedSize).toStringAsFixed(2)} sats/vB",
                style: Theme.of(context).textTheme.bodyMedium,
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
                      .read<ReplaceByFeeFormBloc>()
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
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  HorizonUI.HorizonCancelButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    buttonText: 'CANCEL',
                  ),
                  HorizonUI.HorizonContinueButton(
                    loading: state.submissionStatus.isInProgress,
                    onPressed: state.submissionStatus.isInProgress
                        ? () {}
                        : () {
                            context
                                .read<ReplaceByFeeFormBloc>()
                                .add(FormSubmitted(
                                    tx: data.tx,
                                    hex: data.hex,
                                    adjustedVirtualSize: data.adjustedSize,
                                    newFeeRate: switch (state.feeEstimates) {
                                      Success(data: var feeEstimates) =>
                                        switch (state.feeOption) {
                                          FeeOption.Fast() => feeEstimates.fast,
                                          FeeOption.Medium() =>
                                            feeEstimates.medium,
                                          FeeOption.Slow() => feeEstimates.slow,
                                          FeeOption.Custom(fee: var fee) => fee,
                                        },
                                      _ => throw Exception("invariant")
                                    }));
                          },
                    buttonText: 'CONTINUE',
                  ),
                ],
              ),
            ]),
          ),
        _ => const SizedBox.shrink()
      };
    });

    return const Text("Replace by fee form");
  }
}
