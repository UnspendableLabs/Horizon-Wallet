import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/transaction_stepper.dart';
import 'package:horizon/presentation/screens/send/bloc/send_bloc.dart';
import 'package:horizon/presentation/screens/send/bloc/send_event.dart';
import 'package:horizon/presentation/screens/send/view/send_confirmation_step.dart';
import 'package:horizon/presentation/screens/send/view/send_inputs_step.dart';
import 'package:horizon/presentation/screens/send/view/send_submission_step.dart';

class SendPage extends StatelessWidget {
  final String assetName;
  final List<String> addresses;

  const SendPage({
    super.key,
    required this.assetName,
    required this.addresses,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SendBloc(
        balanceRepository: GetIt.I<BalanceRepository>(),
      )..add(SendDependenciesRequested(
          assetName: assetName, addresses: addresses)),
      child: BlocConsumer<SendBloc, TransactionState<SendData>>(
        listener: (context, state) {
          // Listen for success state to navigate away or show success message
        },
        builder: (context, state) {
          return Scaffold(
            body: TransactionStepper<SendData>(
              // First step - all values extracted by TransactionStepper
              buildInputsStep: (balances, data, isLoading, errorMessage) =>
                  SendInputsStep(
                balances: balances,
                data: data,
                assetName: assetName,
              ),
              // Second step - values extracted by TransactionStepper
              buildConfirmationStep: (balances, data, errorMessage) =>
                  SendConfirmationStep(
                balances: balances,
                data: data,
              ),
              // Third step - handles all states itself
              buildSubmissionStep: (balances, data) => SendSubmissionStep(
                balances: balances,
                data: data,
              ),
              onBack: () => context.pop(),
              state: state,
              nextButtonEnabled:
                  true, // Can be refined based on form validation
              onNextActions: [
                // First step action - dispatches the composed event
                () {
                  // Get form field values - in a real app you'd use Form keys and controllers
                  final formData = state.maybeWhen(
                    success: (_, data) => data,
                    orElse: () => null,
                  );

                  context.read<SendBloc>().add(SendTransactionComposed(
                        destinationAddress: formData?.destinationAddress ?? "",
                        amount: formData?.amount ?? "",
                      ));
                },

                // Second step action - dispatches the submitted event
                () => context.read<SendBloc>().add(SendTransactionSubmitted()),

                // Placeholder for the third step, required by TransactionStepper
                () {}, // No-op for the third step as we don't need it
              ],
            ),
          );
        },
      ),
    );
  }
}
