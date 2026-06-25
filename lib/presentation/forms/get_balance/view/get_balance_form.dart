import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:horizon/presentation/forms/get_balance/bloc/get_balance_bloc.dart';
import 'package:horizon/presentation/forms/get_balance/bloc/get_balance_state.dart';

/// `getBalance` is a read-only request over data that is already public on
/// chain (and for an address the dApp already learned at connect time), so it
/// auto-resolves once fetched rather than asking the user to approve a balance
/// read. The popup shows a brief spinner, then returns the balance and closes.
class GetBalanceForm extends StatelessWidget {
  final void Function(String confirmed, String unconfirmed, String total)
      onSuccess;
  // A balance read can only fail fatally (network/unreachable); there is nothing
  // to retry, so surface the real error to the dApp and let it close the popup.
  final void Function(String error) onError;

  const GetBalanceForm(
      {super.key, required this.onSuccess, required this.onError});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GetBalanceBloc, GetBalanceState>(
      listener: (context, state) {
        if (state.status == GetBalanceStatus.success) {
          onSuccess(
            state.confirmed.toString(),
            state.unconfirmed.toString(),
            state.total.toString(),
          );
        } else if (state.status == GetBalanceStatus.failure) {
          onError(state.error ?? 'Failed to fetch balance');
        }
      },
      child: BlocBuilder<GetBalanceBloc, GetBalanceState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: switch (state.status) {
              GetBalanceStatus.failure => Text(
                  state.error ?? 'Failed to fetch balance',
                  style: const TextStyle(color: Colors.red),
                ),
              _ => const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator()],
                ),
            },
          );
        },
      ),
    );
  }
}
