import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/transaction_stepper.dart';
import 'package:horizon/presentation/screens/send/bloc/send_bloc.dart';
import 'package:horizon/presentation/screens/send/bloc/send_event.dart';
import 'package:horizon/presentation/screens/send/bloc/send_state.dart';
import 'package:horizon/presentation/screens/send/view/send_confirmation_step.dart';
import 'package:horizon/presentation/screens/send/view/send_inputs_step.dart';
import 'package:horizon/presentation/screens/send/view/send_submission_step.dart';

class SendPage extends StatelessWidget {
  const SendPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SendBloc()..add(SendDependenciesRequested()),
      child: BlocConsumer<SendBloc, SendState>(
        listener: (context, state) {
          // Listen for success state to navigate away or show success message
        },
        builder: (context, state) {
          return Scaffold(
            body: TransactionStepper(
              transactionInputs: SendInputsStep(
                state: state,
              ),
              transactionConfirmation: SendConfirmationStep(state: state),
              transactionSubmission: SendSubmissionStep(state: state),
              onBack: () => context.pop(),
              isLoading: state.isLoading,
              nextButtonEnabled: state.error == null,
              onNextActions: [
                // First step action - dispatches the composed event
                () => context.read<SendBloc>().add(SendTransactionComposed()),

                // Second step action - dispatches the submitted event
                () => context.read<SendBloc>().add(SendTransactionSubmitted()),

                // Third step action - dispatches the signed event
                () => context.read<SendBloc>().add(SendTransactionSigned()),
              ],
            ),
          );
        },
      ),
    );
  }
}
