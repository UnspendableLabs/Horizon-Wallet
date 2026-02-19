import 'package:formz/formz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/forms/get_bls_pop/bloc/get_bls_pop_bloc.dart';
import 'package:horizon/presentation/forms/get_bls_pop/bloc/get_bls_pop_state.dart';
import 'package:horizon/presentation/forms/get_bls_pop/bloc/get_bls_pop_event.dart';

import 'package:horizon/presentation/screens/horizon/redesign_ui.dart'
    as HorizonUI;
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

class GetBLSPoPForm extends StatefulWidget {
  final bool passwordRequired;
  final void Function(String xpubkey, String blsPubkey, String schnorrSig, String blsSig) onSuccess;

  const GetBLSPoPForm(
      {super.key, required this.onSuccess, required this.passwordRequired});

  @override
  State<GetBLSPoPForm> createState() => _GetBLSPoPFormState();
}

class _GetBLSPoPFormState extends State<GetBLSPoPForm> {
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GetBLSPoPBloc, GetBLSPoPState>(
      listener: (context, state) {
        if (state.submissionStatus.isSuccess) {
          widget.onSuccess(state.xpubkey!, state.blsPubkey!, state.schnorrSig!, state.blsSig!);
        }
      },
      child: BlocBuilder<GetBLSPoPBloc, GetBLSPoPState>(
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
                  "BLS Proof of Possession",
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(height: 20),
                Text(
                  "Link your Taproot identity to a BLS key",
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  "Address: ${state.address}",
                  style: theme.textTheme.bodySmall,
                ),
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
                              .read<GetBLSPoPBloc>()
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
                                .read<GetBLSPoPBloc>()
                                .add(GetBLSPoPSubmitted()),
                        child: state.submissionStatus.isInProgress
                            ? HorizonUI.WidgetButtonContent(
                                value: const CircularProgressIndicator())
                            : HorizonUI.TextButtonContent(
                                value: 'Generate Proof of Possession'),
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
                    'Proof of Possession generated',
                    style: TextStyle(color: Colors.green),
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
