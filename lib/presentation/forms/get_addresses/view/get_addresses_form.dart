import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:formz/formz.dart";

import 'package:horizon/presentation/forms/get_addresses/bloc/get_addresses_bloc.dart';
import 'package:horizon/presentation/forms/get_addresses/bloc/get_addresses_state.dart';
import 'package:horizon/presentation/forms/get_addresses/bloc/get_addresses_event.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';

class GetAddressesForm extends StatelessWidget {
  final List<Account> accounts;
  final void Function(List<Address> addresses) onSuccess;

  const GetAddressesForm({
    super.key,
    required this.accounts,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<GetAddressesBloc, GetAddressesState>(
      listener: (context, state) {
        if (state.submissionStatus.isSuccess && state.addresses != null) {
          onSuccess(state
              .addresses!); // Call the onSuccess callback with the addresses
        }
      },
      child: BlocBuilder<GetAddressesBloc, GetAddressesState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value:
                      state.account.value.isEmpty ? null : state.account.value,
                  onChanged: (value) {
                    if (value != null) {
                      context
                          .read<GetAddressesBloc>()
                          .add(AccountChanged(value));
                    }
                  },
                  items: accounts.map<DropdownMenuItem<String>>((account) {
                    return DropdownMenuItem(
                      value: account.uuid,
                      child: Text(account.name),
                    );
                  }).toList(),
                  hint: const Text('Select an Account'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: state.submissionStatus.isInProgressOrSuccess
                      ? null
                      : () => context
                          .read<GetAddressesBloc>()
                          .add(GetAddressesSubmitted()),
                  child: state.submissionStatus.isInProgress
                      ? const CircularProgressIndicator()
                      : const Text('Approve Request'),
                ),
                if (state.submissionStatus.isFailure) ...[
                  const SizedBox(height: 20),
                  Text(
                    state.error!,
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
