import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/forms/get_addresses/bloc/get_addresses_bloc.dart';
import 'package:horizon/presentation/forms/get_addresses/bloc/get_addresses_state.dart';
import 'package:horizon/presentation/forms/get_addresses/bloc/get_addresses_event.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/imported_address.dart';
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
                      print("coool $address");
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
