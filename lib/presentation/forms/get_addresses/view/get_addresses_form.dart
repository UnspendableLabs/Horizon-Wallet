import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/forms/get_addresses/bloc/get_addresses_bloc.dart';
import 'package:horizon/presentation/forms/get_addresses/bloc/get_addresses_state.dart';
import 'package:horizon/presentation/forms/get_addresses/bloc/get_addresses_event.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address_rpc.dart';

class GetAddressesForm extends StatelessWidget {
  final List<Account> accounts;
  final void Function(List<AddressRpc>) onSuccess;

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
          onSuccess(state.addresses!);
        }
      },
      child: BlocBuilder<GetAddressesBloc, GetAddressesState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mode Selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Radio<AddressSelectionMode>(
                      value: AddressSelectionMode.byAccount,
                      groupValue: state.addressSelectionMode,
                      onChanged: (mode) {
                        context
                            .read<GetAddressesBloc>()
                            .add(AddressSelectionModeChanged(mode!));
                      },
                    ),
                    const Text('All Addresses in Account'),
                    Radio<AddressSelectionMode>(
                      value: AddressSelectionMode.importedAddresses,
                      groupValue: state.addressSelectionMode,
                      onChanged: (mode) {
                        context
                            .read<GetAddressesBloc>()
                            .add(AddressSelectionModeChanged(mode!));
                      },
                    ),
                    const Text('Imported Addresses'),
                  ],
                ),

                const SizedBox(height: 20),

                // Conditionally render dropdown based on mode
                if (state.addressSelectionMode ==
                    AddressSelectionMode.byAccount) ...[
                  DropdownButton<String>(
                    value: state.account.value.isEmpty
                        ? null
                        : state.account.value,
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
                ] else if (state.addressSelectionMode ==
                        AddressSelectionMode.importedAddresses &&
                    state.importedAddresses != null) ...[
                  DropdownButton<String>(
                    value: state.importedAddress.value.isEmpty
                        ? null
                        : state.importedAddress.value,
                    onChanged: (address) {
                      if (address != null) {
                        context
                            .read<GetAddressesBloc>()
                            .add(ImportedAddressSelected(address));
                      }
                    },
                    items: state.importedAddresses!
                        .map<DropdownMenuItem<String>>((address) {
                      return DropdownMenuItem(
                        value: address.address,
                        child: Text(address.address),
                      );
                    }).toList(),
                    hint: const Text('Select an Imported Address'),
                  ),
                ],

                const SizedBox(height: 20),
                TextField(
                  onChanged: (password) => context
                      .read<GetAddressesBloc>()
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: state.warningAccepted,
                      onChanged: (value) {
                        context
                            .read<GetAddressesBloc>()
                            .add(WarningAcceptedChanged(value ?? false));
                      },
                      fillColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          return mainTextGreyTransparent;
                        },
                      ),
                    ),
                    Expanded(
                      child: SelectableText(
                        'If you use this address in a wallet that does not support Counterparty there is a very high risk of losing your UTXO-attached asset. Please confirm that you understand the risks.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Submit Button
                ElevatedButton(
                  onPressed: state.submissionStatus.isInProgressOrSuccess ||
                          !state.warningAccepted ||
                          state.password.value.isEmpty ||
                          (state.addressSelectionMode ==
                                  AddressSelectionMode.byAccount &&
                              state.account.value.isEmpty) ||
                          (state.addressSelectionMode ==
                                  AddressSelectionMode.importedAddresses &&
                              state.importedAddress.value.isEmpty)
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
                    state.error ?? 'An error occurred',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],

                if (state.submissionStatus.isSuccess) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Success!',
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
