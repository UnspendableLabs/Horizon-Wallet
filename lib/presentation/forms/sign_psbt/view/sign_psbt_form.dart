import 'package:formz/formz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_bloc.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_state.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_event.dart';

class SignPsbtForm extends StatefulWidget {
  final void Function(String) onSuccess;

  const SignPsbtForm({super.key, required this.onSuccess});

  @override
  State<SignPsbtForm> createState() => _SignPsbtFormState();
}

class _SignPsbtFormState extends State<SignPsbtForm> {
  @override
  void initState() {
    super.initState();
    context.read<SignPsbtBloc>().add(FetchFormEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignPsbtBloc, SignPsbtState>(
      listener: (context, state) {
        if (state.submissionStatus.isSuccess) {
          widget.onSuccess(state.signedPsbt!);
        }
      },
      child: BlocBuilder<SignPsbtBloc, SignPsbtState>(
        builder: (context, state) {
          if (!state.isFormDataLoaded) {
            // Display a loading indicator while data is being fetched
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // Once data is loaded, display the form
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Transaction Details Section
                const Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Conditional display based on psbtSignType
                if (state.psbtSignType == PsbtSignTypeEnum.buy) ...[
                  SelectableText(
                    'Swap ${state.bitcoinAmount!.toStringAsFixed(8)} BTC for ${state.getAmount} ${state.asset}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    'TX fee: ${state.fee?.toStringAsFixed(8)} BTC',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    'Total BTC to be sent: ${(state.fee! + state.bitcoinAmount!).toStringAsFixed(8)} BTC',
                    style: const TextStyle(fontSize: 16),
                  ),
                ] else ...[
                  SelectableText(
                    'Swap ${state.getAmount} ${state.asset} for ${state.bitcoinAmount!.toStringAsFixed(8)} BTC',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],

                const SizedBox(height: 20),
                // Password Field
                TextField(
                  onChanged: (password) => context
                      .read<SignPsbtBloc>()
                      .add(PasswordChanged(password)),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: state.password.displayError == null
                        ? null
                        : 'Password cannot be empty',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                // Submit Button
                ElevatedButton(
                  onPressed: state.submissionStatus.isInProgressOrSuccess
                      ? null
                      : () =>
                          context.read<SignPsbtBloc>().add(SignPsbtSubmitted()),
                  child: state.submissionStatus.isInProgress
                      ? const CircularProgressIndicator()
                      : const Text('Sign PSBT'),
                ),
                const SizedBox(height: 20),
                // Status/Error Message
                if (state.submissionStatus.isFailure) ...[
                  Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ] else if (state.submissionStatus.isSuccess) ...[
                  const Text(
                    'Transaction signed successfully!',
                    style: TextStyle(color: Colors.green),
                  ),
                  // Show the signed PSBT if needed
                  if (state.signedPsbt != null)
                    SelectableText(
                      'Signed PSBT: ${state.signedPsbt}',
                      style: const TextStyle(color: Colors.black),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
