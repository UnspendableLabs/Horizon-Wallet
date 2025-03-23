import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/transaction_stepper.dart';
import 'package:horizon/presentation/common/transactions/gradient_quantity_input.dart';
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
  MultiAddressBalanceEntry? selectedBalanceEntry;
  TextEditingController quantityController = TextEditingController();

  void _handleInputsStepNext(
      BuildContext context, TransactionState<SendData> state) {
    final formData = state.maybeWhen(
      success: (_, data) => data,
      orElse: () => null,
    );

    context.read<SendBloc>().add(SendTransactionComposed(
          destinationAddress: formData?.destinationAddress ?? "",
          amount: formData?.amount ?? "",
        ));
  }

  void _handleConfirmationStepNext(BuildContext context) {
    context.read<SendBloc>().add(SendTransactionSubmitted());
  }

  void _handleSubmissionStepNext(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SendBloc(
        balanceRepository: GetIt.I<BalanceRepository>(),
      )..add(SendDependenciesRequested(
          assetName: widget.assetName, addresses: widget.addresses)),
      child: BlocConsumer<SendBloc, TransactionState<SendData>>(
        listener: (context, state) {
          // TODO: Implement listener
        },
        builder: (context, state) {
          return Scaffold(
            body: TransactionStepper<SendData>(
              buildInputsStep: (balance, data, isLoading, errorMessage) =>
                  StepContent(
                title: 'Enter Send Details',
                widgets: [
                  MultiAddressBalanceDropdown(
                    balances: balance,
                    onChanged: (value) {
                      setState(() {
                        selectedBalanceEntry = value;
                        quantityController.clear();
                      });
                    },
                    selectedValue: selectedBalanceEntry,
                  ),
                  commonHeightSizedBox,
                  TokenNameField(
                      balance: balance,
                      selectedBalanceEntry: selectedBalanceEntry),
                  commonHeightSizedBox,
                  GradientNumberInput(
                    showMaxButton: true,
                    balance: balance,
                    selectedBalanceEntry: selectedBalanceEntry,
                    controller: quantityController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }

                      if (selectedBalanceEntry != null && balance != null) {
                        try {
                          final enteredQuantity = getQuantityForDivisibility(
                            divisible: balance.assetInfo.divisible,
                            inputQuantity: value,
                          );

                          if (enteredQuantity >
                              selectedBalanceEntry!.quantity) {
                            return 'Insufficient balance';
                          }
                        } catch (e) {
                          return 'Invalid amount';
                        }
                      }

                      return null;
                    },
                  )
                ],
              ),
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
              nextButtonEnabled: true,
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
