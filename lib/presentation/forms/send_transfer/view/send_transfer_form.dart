import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:horizon/presentation/forms/send_transfer/bloc/send_transfer_bloc.dart';
import 'package:horizon/presentation/forms/send_transfer/bloc/send_transfer_state.dart';
import 'package:horizon/presentation/forms/send_transfer/bloc/send_transfer_event.dart';

import 'package:horizon/presentation/screens/horizon/redesign_ui.dart'
    as HorizonUI;
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

class SendTransferForm extends StatefulWidget {
  final bool passwordRequired;
  final String destination;
  final int amount; // satoshis
  final String source;
  final void Function(String txid) onSuccess;
  // Fired only for a fatal compose failure (nothing to retry): the dApp is
  // notified and the popup closes. Broadcast failures stay on screen for retry.
  final void Function(String error) onError;

  const SendTransferForm({
    super.key,
    required this.passwordRequired,
    required this.destination,
    required this.amount,
    required this.source,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<SendTransferForm> createState() => _SendTransferFormState();
}

class _SendTransferFormState extends State<SendTransferForm> {
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<SendTransferBloc, SendTransferState>(
      listener: (context, state) {
        if (state.status == SendTransferStatus.success && state.txid != null) {
          widget.onSuccess(state.txid!);
        } else if (state.status == SendTransferStatus.composeFailure) {
          widget.onError(state.error ?? 'Transaction failed');
        }
      },
      child: BlocBuilder<SendTransferBloc, SendTransferState>(
        builder: (context, state) {
          if (state.status == SendTransferStatus.composing) {
            return const Padding(
              padding: EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator()],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _row(theme, 'To', widget.destination),
                const SizedBox(height: 12),
                _row(theme, 'Amount', '${widget.amount} sats'),
                const SizedBox(height: 12),
                _row(theme, 'From', widget.source),
                const SizedBox(height: 12),
                _row(theme, 'Network fee',
                    state.feeSats > 0 ? '${state.feeSats} sats' : '—'),
                const SizedBox(height: 12),
                const Divider(),
                if (widget.passwordRequired)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                    child: HorizonTextField(
                      controller: passwordController,
                      enabled:
                          state.status != SendTransferStatus.broadcasting,
                      onChanged: (password) => context
                          .read<SendTransferBloc>()
                          .add(PasswordChanged(password)),
                      hintText: 'Password',
                      obscureText: true,
                      errorText: state.password.displayError != null
                          ? 'Password cannot be empty'
                          : null,
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: HorizonUI.HorizonButton(
                        onPressed: (state.status ==
                                    SendTransferStatus.broadcasting ||
                                state.status == SendTransferStatus.success ||
                                (widget.passwordRequired &&
                                    !state.password.isValid))
                            ? null
                            : () => context
                                .read<SendTransferBloc>()
                                .add(ConfirmSend()),
                        child: state.status == SendTransferStatus.broadcasting
                            ? HorizonUI.WidgetButtonContent(
                                value: const CircularProgressIndicator())
                            : HorizonUI.TextButtonContent(
                                value: 'Confirm & Send'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state.status == SendTransferStatus.composeFailure ||
                    state.status == SendTransferStatus.broadcastFailure)
                  Text(
                    state.error ?? 'Transaction failed',
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 4),
        SelectableText(value),
      ],
    );
  }
}
