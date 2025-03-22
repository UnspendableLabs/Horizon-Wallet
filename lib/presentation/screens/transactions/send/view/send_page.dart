import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/transaction_stepper.dart';
import 'package:horizon/presentation/common/transactions/multi_address_balance_dropdown.dart';
import 'package:horizon/presentation/common/transactions/token_name_field.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/screens/transactions/send/bloc/send_bloc.dart';
import 'package:horizon/presentation/screens/transactions/send/bloc/send_event.dart';

class SendPage extends StatefulWidget {
  final String assetName;
  final List<String> addresses;

  const SendPage({
    super.key,
    required this.assetName,
    required this.addresses,
  });

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  MultiAddressBalanceEntry? selectedBalance;

  // Handler for the inputs step "Next" button
  void _handleInputsStepNext(
      BuildContext context, TransactionState<SendData> state) {
    // Get form field values - in a real app you'd use Form keys and controllers
    final formData = state.maybeWhen(
      success: (_, data) => data,
      orElse: () => null,
    );

    context.read<SendBloc>().add(SendTransactionComposed(
          destinationAddress: formData?.destinationAddress ?? "",
          amount: formData?.amount ?? "",
        ));
  }

  // Handler for the confirmation step "Next" button
  void _handleConfirmationStepNext(BuildContext context) {
    context.read<SendBloc>().add(SendTransactionSubmitted());
  }

  // Handler for the submission step "Next" button (no-op as it's not used)
  void _handleSubmissionStepNext(BuildContext context) {
    // No-op for the third step as we don't need it
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SendBloc(
        balanceRepository: GetIt.I<BalanceRepository>(),
      )..add(SendDependenciesRequested(
          assetName: widget.assetName, addresses: widget.addresses)),
      child: BlocConsumer<SendBloc, TransactionState<SendData>>(
        listener: (context, state) {
          // Listen for success state to navigate away or show success message
        },
        builder: (context, state) {
          return Scaffold(
            body: TransactionStepper<SendData>(
              // First step - all values extracted by TransactionStepper
              buildInputsStep: (balance, data, isLoading, errorMessage) =>
                  StepContent(
                title: 'Enter Send Details',
                widgets: [
                  MultiAddressBalanceDropdown(
                    balances: balance,
                    onChanged: (value) {
                      setState(() {
                        selectedBalance = value;
                      });
                    },
                    selectedValue: selectedBalance,
                  ),
                  commonHeightSizedBox,
                  TokenNameField(balance: balance)
                ],
              ),
              // Second step - values extracted by TransactionStepper
              buildConfirmationStep: (balances, data, errorMessage) =>
                  const StepContent(
                title: 'Confirm Transaction',
                widgets: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Review your send details'),
                  ),
                ],
              ),
              // Third step - handles all states itself
              buildSubmissionStep: (balances, data) => const StepContent(
                title: 'Transaction Submitted',
                widgets: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Your transaction is being processed'),
                  ),
                ],
              ),
              onBack: () => context.pop(),
              state: state,
              nextButtonEnabled:
                  true, // Can be refined based on form validation
              onInputsStepNext: () => _handleInputsStepNext(context, state),
              onConfirmationStepNext: () =>
                  _handleConfirmationStepNext(context),
              onSubmissionStepNext: () => _handleSubmissionStepNext(context),
            ),
          );
        },
      ),
    );
  }
}
