import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/account_v2.dart';
import 'package:horizon/domain/entities/address_rpc.dart';
import 'package:horizon/presentation/forms/get_addresses/bloc/get_addresses_bloc.dart';
import 'package:horizon/presentation/forms/get_addresses/bloc/get_addresses_event.dart';
import 'package:horizon/presentation/forms/get_addresses/bloc/get_addresses_state.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart' as HorizonUI;
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';

class GetAddressesForm extends StatelessWidget {
  final bool passwordRequired;
  final List<AccountV2> accounts;
  final void Function(List<AddressRpc>) onSuccess;
  final VoidCallback onCancel;

  const GetAddressesForm({
    super.key,
    required this.passwordRequired,
    required this.accounts,
    required this.onSuccess,
    required this.onCancel,
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: AppIcons.shieldIcon(
                          context: context,
                          width: 32,
                          height: 32,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CONNECT APP',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Requested by horizon.market',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Mode Selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Radio<AddressSelectionMode>(
                      activeColor: green2,
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
                      activeColor: green2,
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
                  HorizonUI.HorizonRedesignDropdown<String>(
                    selectedValue: state.account.value.isEmpty
                        ? null
                        : state.account.value,
                    onChanged: (value) {
                      final account = accounts.firstWhere(
                        (account) => account.hash == value,
                      );
                      if (value != null) {
                        context
                            .read<GetAddressesBloc>()
                            .add(AccountChanged(account));
                      }
                    },
                    items: accounts.map((account) {
                      return DropdownMenuItem(
                        value: account.hash,
                        child: Text(account.name),
                      );
                    }).toList(),
                    hintText: 'Select an Account',
                  ),
                ] else if (state.addressSelectionMode ==
                        AddressSelectionMode.importedAddresses &&
                    state.importedAddresses != null) ...[
                  HorizonUI.HorizonRedesignDropdown<String>(
                    selectedValue: state.importedAddress.value.isEmpty
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
                        .map((address) => DropdownMenuItem(
                              value: address.address,
                              child: Text(address.address),
                            ))
                        .toList(),
                    hintText: 'Select an Imported Address',
                  ),
                ],

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
                      activeColor: green2,
                      checkColor: Colors.white,
                      side: const BorderSide(color: green2, width: 2),
                    ),
                    const Expanded(
                      child: SelectableText(
                        'If you use this address in a wallet that does not support Counterparty there is a very high risk of losing your UTXO-attached asset. Please confirm that you understand the risks.',
                      ),
                    ),
                  ],
                ),
                if (passwordRequired) ...[
                  const SizedBox(height: 24),
                  HorizonUI.HorizonTextField(
                    controller:
                        TextEditingController(text: state.password.value),
                    onChanged: (password) =>
                        context.read<GetAddressesBloc>().add(PasswordChanged(password)),
                    hintText: 'Password',
                    obscureText: true,
                    errorText: state.password.displayError != null
                        ? 'Password cannot be empty'
                        : null,
                  ),
                ],
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: HorizonUI.HorizonButton(
                        onPressed: onCancel,
                        variant: HorizonUI.ButtonVariant.black,
                        child: HorizonUI.TextButtonContent(value: 'Deny'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: HorizonUI.HorizonButton(
                        disabled:
                            state.submissionStatus.isInProgressOrSuccess ||
                                !state.warningAccepted ||
                                (state.password.value.isEmpty &&
                                    passwordRequired) ||
                                (state.addressSelectionMode ==
                                        AddressSelectionMode.byAccount &&
                                    state.account.value.isEmpty) ||
                                (state.addressSelectionMode ==
                                        AddressSelectionMode
                                            .importedAddresses &&
                                    state.importedAddress.value.isEmpty),
                        onPressed: () => context.read<GetAddressesBloc>().add(GetAddressesSubmitted()),
                        variant: HorizonUI.ButtonVariant.green,
                        child: HorizonUI.TextButtonContent(value: 'Confirm'),
                        isLoading: state.submissionStatus.isInProgress,
                      ),
                    ),
                  ],
                ),
                if (state.submissionStatus.isFailure) ...[
                  const SizedBox(height: 16),
                  Text(
                    state.error ?? 'An error occurred',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
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