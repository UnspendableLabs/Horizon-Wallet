import 'package:formz/formz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/forms/sign_message/bloc/sign_message_bloc.dart';
import 'package:horizon/presentation/forms/sign_message/bloc/sign_message_state.dart';
import 'package:horizon/presentation/forms/sign_message/bloc/sign_message_event.dart';

class SignMessageForm extends StatefulWidget {
  final bool passwordRequired;

  final void Function(String) onSuccess;

  const SignMessageForm(
      {super.key, required this.onSuccess, required this.passwordRequired});

  @override
  State<SignMessageForm> createState() => _SignMessageFormState();
}

class _SignMessageFormState extends State<SignMessageForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignMessageBloc, SignMessageState>(
      listener: (context, state) {
        if (state.submissionStatus.isSuccess) {
          widget.onSuccess(state.signature!);
        }
      },
      child: BlocBuilder<SignMessageBloc, SignMessageState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                // Password Field
                if (widget.passwordRequired)
                  TextField(
                    onChanged: (password) => context
                        .read<SignMessageBloc>()
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
                      : () => context
                          .read<SignMessageBloc>()
                          .add(SignMessageSubmitted()),
                  child: state.submissionStatus.isInProgress
                      ? const CircularProgressIndicator()
                      : const Text('Sign Message'),
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
                    'Signed message',
                    style: TextStyle(color: Colors.green),
                  ),
                  // Show the signed MESSAGE if needed
                  if (state.signature != null)
                    SelectableText(
                      'Signed MESSAGE: ${state.signature}',
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
