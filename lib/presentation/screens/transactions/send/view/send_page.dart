import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/transaction_stepper.dart';
import 'package:horizon/presentation/common/transactions/gradient_quantity_input.dart';
import 'package:horizon/presentation/common/transactions/multi_address_balance_dropdown.dart';
import 'package:horizon/presentation/common/transactions/token_name_field.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/screens/transactions/send/bloc/send_bloc.dart';
import 'package:horizon/presentation/screens/transactions/send/bloc/send_event.dart';
import 'package:horizon/presentation/screens/transactions/send/bloc/send_state.dart';

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
  TextEditingController destinationAddressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _handleInputsStepNext(
      BuildContext context, TransactionState<SendState> state) {
    final quantity = getQuantityForDivisibility(
      divisible: state.getBalancesOrThrow().assetInfo.divisible,
      inputQuantity: quantityController.text,
    );
    context.read<SendBloc>().add(SendTransactionComposed(
          sourceAddress: selectedBalanceEntry?.address ?? "",
          params: SendTransactionParams(
            destinationAddress: destinationAddressController.text,
            asset: widget.assetName,
            quantity: quantity,
          ),
        ));
  }

  void _handleConfirmationStepNext(BuildContext context) {
    context.read<SendBloc>().add(SendTransactionSubmitted());
  }

  void _handleSubmissionStepNext(BuildContext context) {}

  void _handleFeeOptionSelected(BuildContext context, FeeOption feeOption) {
    context.read<SendBloc>().add(FeeOptionSelected(feeOption: feeOption));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SendBloc(
        balanceRepository: GetIt.I<BalanceRepository>(),
        getFeeEstimatesUseCase: GetIt.I<GetFeeEstimatesUseCase>(),
        composeTransactionUseCase: GetIt.I<ComposeTransactionUseCase>(),
        composeRepository: GetIt.I<ComposeRepository>(),
      )..add(SendDependenciesRequested(
          assetName: widget.assetName, addresses: widget.addresses)),
      child: BlocConsumer<SendBloc, TransactionState<SendState>>(
        listener: (context, state) {
          // TODO: Implement listener
        },
        builder: (context, state) {
          return Scaffold(
            body: TransactionStepper<SendState>(
              formKey: _formKey,
              buildFormStep: (balances, feeEstimates, feeOption, data) =>
                  StepContent(
                title: 'Enter Send Details',
                widgets: [
                  MultiAddressBalanceDropdown(
                    balances: balances,
                    onChanged: (value) {
                      setState(() {
                        selectedBalanceEntry = value;
                        quantityController.clear();
                      });
                    },
                    selectedValue: selectedBalanceEntry,
                  ),
                  commonHeightSizedBox,
                  HorizonTextField(
                    controller: destinationAddressController,
                    label: 'Destination Address',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a destination address';
                      }

                      return null;
                    },
                  ),
                  commonHeightSizedBox,
                  TokenNameField(
                      balance: balances,
                      selectedBalanceEntry: selectedBalanceEntry),
                  commonHeightSizedBox,
                  GradientQuantityInput(
                    showMaxButton: true,
                    balance: balances,
                    selectedBalanceEntry: selectedBalanceEntry,
                    controller: quantityController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }

                      if (selectedBalanceEntry != null && balances != null) {
                        try {
                          final enteredQuantity = getQuantityForDivisibility(
                            divisible: balances.assetInfo.divisible ?? false,
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
              buildConfirmationStep:
                  (balances, feeEstimates, feeOption, data) =>
                      const StepContent(
                title: 'Confirm Transaction',
                widgets: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Review your send details'),
                  ),
                ],
              ),
              buildSubmissionStep: (balances, feeEstimates, feeOption, data) =>
                  const StepContent(
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
              onFormStepNext: () => _handleInputsStepNext(context, state),
              onConfirmationStepNext: () =>
                  _handleConfirmationStepNext(context),
              onSubmissionStepNext: () => _handleSubmissionStepNext(context),
              onFeeOptionSelected: (feeOption) =>
                  _handleFeeOptionSelected(context, feeOption),
            ),
          );
        },
      ),
    );
  }
}
