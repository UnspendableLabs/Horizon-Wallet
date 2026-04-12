import 'package:formz/formz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/forms/export_encrypted_bls_private_key/bloc/export_encrypted_bls_private_key_bloc.dart';
import 'package:horizon/presentation/forms/export_encrypted_bls_private_key/bloc/export_encrypted_bls_private_key_state.dart';
import 'package:horizon/presentation/forms/export_encrypted_bls_private_key/bloc/export_encrypted_bls_private_key_event.dart';

import 'package:horizon/presentation/screens/horizon/redesign_ui.dart'
    as HorizonUI;
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

class ExportEncryptedBlsPrivateKeyForm extends StatefulWidget {
  final bool passwordRequired;
  final void Function(String encryptedBlsPrivateKey) onSuccess;

  const ExportEncryptedBlsPrivateKeyForm({
    super.key,
    required this.onSuccess,
    required this.passwordRequired,
  });

  @override
  State<ExportEncryptedBlsPrivateKeyForm> createState() =>
      _ExportEncryptedBlsPrivateKeyFormState();
}

class _ExportEncryptedBlsPrivateKeyFormState
    extends State<ExportEncryptedBlsPrivateKeyForm> {
  final _walletPasswordController = TextEditingController();
  final _exportPasswordController = TextEditingController();
  final _confirmExportPasswordController = TextEditingController();

  @override
  void dispose() {
    _walletPasswordController.dispose();
    _exportPasswordController.dispose();
    _confirmExportPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExportEncryptedBlsPrivateKeyBloc,
        ExportEncryptedBlsPrivateKeyState>(
      listener: (context, state) {
        if (state.submissionStatus.isSuccess) {
          widget.onSuccess(state.encryptedBlsPrivateKey!);
        }
      },
      child: BlocBuilder<ExportEncryptedBlsPrivateKeyBloc,
          ExportEncryptedBlsPrivateKeyState>(
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
                  "This will export your BLS private key encrypted with the export password you provide below.",
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                const Divider(),

                if (widget.passwordRequired)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                        child: Text(
                          "Wallet password",
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                      HorizonTextField(
                        controller: _walletPasswordController,
                        onChanged: (password) => context
                            .read<ExportEncryptedBlsPrivateKeyBloc>()
                            .add(WalletPasswordChanged(password)),
                        hintText: 'Enter your wallet password',
                        obscureText: true,
                        errorText: state.walletPassword.displayError != null
                            ? 'Wallet password cannot be empty'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                    ],
                  ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                      child: Text(
                        "Export password",
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                    Text(
                      "For stronger security, prefer a password that is different from your wallet password.",
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    HorizonTextField(
                      controller: _exportPasswordController,
                      onChanged: (password) => context
                          .read<ExportEncryptedBlsPrivateKeyBloc>()
                          .add(ExportPasswordChanged(password)),
                      hintText: 'Choose an export password',
                      obscureText: true,
                      errorText: state.exportPassword.displayError != null
                          ? 'Export password cannot be empty'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    HorizonTextField(
                      controller: _confirmExportPasswordController,
                      onChanged: (password) => context
                          .read<ExportEncryptedBlsPrivateKeyBloc>()
                          .add(ConfirmExportPasswordChanged(password)),
                      hintText: 'Confirm export password',
                      obscureText: true,
                      errorText:
                          state.confirmExportPassword.displayError != null
                              ? 'Confirmation cannot be empty'
                              : null,
                    ),
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
                                .read<ExportEncryptedBlsPrivateKeyBloc>()
                                .add(ExportEncryptedBlsPrivateKeySubmitted()),
                        child: state.submissionStatus.isInProgress
                            ? HorizonUI.WidgetButtonContent(
                                value: const CircularProgressIndicator())
                            : HorizonUI.TextButtonContent(
                                value: 'Export BLS Key'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (state.submissionStatus.isFailure) ...[
                  Text(
                    state.error ?? 'An unknown error occurred',
                    style: const TextStyle(color: Colors.red),
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
