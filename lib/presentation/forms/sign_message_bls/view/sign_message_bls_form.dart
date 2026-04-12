import 'package:formz/formz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/forms/sign_message_bls/bloc/sign_message_bls_bloc.dart';
import 'package:horizon/presentation/forms/sign_message_bls/bloc/sign_message_bls_state.dart';
import 'package:horizon/presentation/forms/sign_message_bls/bloc/sign_message_bls_event.dart';

import 'package:horizon/presentation/screens/horizon/redesign_ui.dart'
    as HorizonUI;
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

class SignMessageBLSForm extends StatefulWidget {
  final bool passwordRequired;
  final void Function(String signature, String publicKey) onSuccess;

  const SignMessageBLSForm(
      {super.key, required this.onSuccess, required this.passwordRequired});

  @override
  State<SignMessageBLSForm> createState() => _SignMessageBLSFormState();
}

class _SignMessageBLSFormState extends State<SignMessageBLSForm> {
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignMessageBLSBloc, SignMessageBLSState>(
      listener: (context, state) {
        if (state.submissionStatus.isSuccess) {
          widget.onSuccess(state.signature!, state.publicKey!);
        }
      },
      child: BlocBuilder<SignMessageBLSBloc, SignMessageBLSState>(
        builder: (context, state) {
          final theme = Theme.of(context);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Message to sign (BLS)",
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(height: 20),
                if (state.message.isNotEmpty)
                  Text(state.message)
                else if (state.messageHex != null)
                  SelectableText(
                    'Binary (hex): ${state.messageHex!.length > 64 ? '${state.messageHex!.substring(0, 64)}...' : state.messageHex!}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                if (state.dst != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    "DST: ${state.dst}",
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 20),
                const Divider(),

                if (widget.passwordRequired)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                        child: HorizonTextField(
                          controller: passwordController,
                          onChanged: (password) => context
                              .read<SignMessageBLSBloc>()
                              .add(PasswordChanged(password)),
                          hintText: 'Password',
                          obscureText: true,
                          errorText: state.password.displayError != null
                              ? 'Password cannot be empty'
                              : null,
                        ),
                      ),
                      const Divider(),
                    ],
                  ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: HorizonUI.HorizonButton(
                        onPressed: state.submissionStatus.isInProgressOrSuccess
                            ? null
                            : () => context
                                .read<SignMessageBLSBloc>()
                                .add(SignMessageBLSSubmitted()),
                        child: state.submissionStatus.isInProgress
                            ? HorizonUI.WidgetButtonContent(
                                value: const CircularProgressIndicator())
                            : HorizonUI.TextButtonContent(
                                value: 'Sign Message (BLS)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (state.submissionStatus.isFailure) ...[
                  Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ] else if (state.submissionStatus.isSuccess) ...[
                  const Text(
                    'Message signed with BLS',
                    style: TextStyle(color: Colors.green),
                  ),
                  if (state.signature != null)
                    SelectableText(
                      'Signature: ${state.signature}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  if (state.publicKey != null)
                    SelectableText(
                      'Public Key: ${state.publicKey}',
                      style: theme.textTheme.bodyMedium,
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
