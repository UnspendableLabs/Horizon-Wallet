import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transactions/error.dart';
import 'package:horizon/presentation/common/transactions/transaction_fee_selection.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

class TransactionFormPage<T> extends StatelessWidget {
  final Form Function(
      {MultiAddressBalance? balances,
      FeeEstimates? feeEstimates,
      T? data,
      FeeOption? feeOption,
      required bool loading}) form;
  final TransactionFormState<T> formState;
  final VoidCallback onErrorButtonAction;
  final String errorButtonText;
  final Function(FeeOption) onFeeOptionSelected;

  const TransactionFormPage({
    super.key,
    required this.form,
    required this.formState,
    required this.errorButtonText,
    required this.onErrorButtonAction,
    required this.onFeeOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (formState.isInitial) {
      return const SizedBox.shrink();
    }
    if (formState.isLoading) {
      final formContent = form(loading: true);

      final formFields = (formContent.child as Column).children;
      formFields.add(commonHeightSizedBox);
      formFields.add(TransactionFeeSelection(
        feeEstimates: null,
        selectedFeeOption: null,
        onFeeOptionSelected: onFeeOptionSelected,
        loading: true,
      ));

      return formContent;
    }
    if (formState.isError) {
      return TransactionError(
        errorMessage: formState.errorMessage,
        onErrorButtonAction: onErrorButtonAction,
        buttonText: errorButtonText,
      );
    }

    final balances = formState.getBalancesOrThrow();
    final feeEstimates = formState.getFeeEstimatesOrThrow();
    final data = formState.getDataOrThrow();
    final feeOption = formState.feeOption;

    final formContent = form(
      balances: balances,
      feeEstimates: feeEstimates,
      data: data,
      feeOption: feeOption,
      loading: false,
    );

    final formFields = (formContent.child as Column).children;
    formFields.add(commonHeightSizedBox);
    formFields.add(TransactionFeeSelection(
      feeEstimates: feeEstimates,
      selectedFeeOption: feeOption,
      onFeeOptionSelected: onFeeOptionSelected,
      loading: false,
    ));

    return formContent;
  }
}
