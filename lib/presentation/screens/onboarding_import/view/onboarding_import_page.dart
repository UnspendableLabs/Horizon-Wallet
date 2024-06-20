import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_event.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_state.dart';

class OnboardingImportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => OnboardingImportBloc(), child: const OnboardingImportPage_());
  }
}

enum ImportFormat {
  segwit("Segwit", "Segwit (BIP84,P2WPKH,Bech32)"),
  // legacy("Legacy", "BIP44,P2PKH,Base58"),
  freewalletBech32("Freewallet-bech32", "Freewallet (Bech32)");

  const ImportFormat(this.name, this.description);
  final String name;
  final String description;
}

class OnboardingImportPage_ extends StatefulWidget {
  const OnboardingImportPage_({super.key});
  @override
  _OnboardingImportPageState createState() => _OnboardingImportPageState();
}

class _OnboardingImportPageState extends State<OnboardingImportPage_> {
  final TextEditingController _passwordController = TextEditingController(text: "");
  final TextEditingController _passwordConfirmationController = TextEditingController(text: "");
  final TextEditingController _seedPhraseController = TextEditingController(text: "");
  final TextEditingController _importFormat = TextEditingController(text: ImportFormat.segwit.name);

  @override
  dispose() {
    _seedPhraseController.dispose();
    _importFormat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingImportBloc, OnboardingImportState>(
      listener: (context, state) {
        if (state.importState is ImportStateSuccess) {
          GoRouter.of(context).go('/dashboard');
        }
      },
      child: BlocBuilder<OnboardingImportBloc, OnboardingImportState>(builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Horizon')),
          body: Flexible(
            child: state.password != null
                ? SeedPrompt(seedPhraseController: _seedPhraseController, state: state)
                : PasswordPrompt(
                    passwordController: _passwordController,
                    passwordConfirmationController: _passwordConfirmationController,
                    state: state,
                  ),
          ),
        );
      }),
    );
  }
}

class PasswordPrompt extends StatelessWidget {
  const PasswordPrompt({
    super.key,
    required TextEditingController passwordController,
    required TextEditingController passwordConfirmationController,
    required OnboardingImportState state,
  })  : _passwordController = passwordController,
        _passwordConfirmationController = passwordConfirmationController,
        _state = state;

  final TextEditingController _passwordController;
  final TextEditingController _passwordConfirmationController;
  final OnboardingImportState _state;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                    constraints:
                        const BoxConstraints(minHeight: 48, minWidth: double.infinity), // Minimum height for the TextField
                    child: TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                    )),
                const SizedBox(height: 16),
                Container(
                  constraints:
                      const BoxConstraints(minHeight: 48, minWidth: double.infinity), // Minimum height for the TextField
                  child: TextField(
                    controller: _passwordConfirmationController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Confirm Password',
                    ),
                  ),
                ),
                _state.passwordError != null ? Text(_state.passwordError!) : const Text(""),
                SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.read<OnboardingImportBloc>().add(
                              PasswordSubmit(
                                password: _passwordController.text,
                                passwordConfirmation: _passwordConfirmationController.text,
                              ),
                            );
                      },
                      child: const Text('Next'),
                    ),
                  ],
                ),
                // state.importState is ImportStateLoading ? CircularProgressIndicator() : const Text("")
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SeedPrompt extends StatelessWidget {
  const SeedPrompt({
    super.key,
    required TextEditingController seedPhraseController,
    required OnboardingImportState state,
  })  : _seedPhraseController = seedPhraseController,
        _state = state;

  final TextEditingController _seedPhraseController;
  final OnboardingImportState _state;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
          margin: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Column(children: [
                TextField(
                  controller: _seedPhraseController,
                  onChanged: (value) {
                    context.read<OnboardingImportBloc>().add(MnemonicChanged(mnemonic: value));
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Seed phrase',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    DropdownMenu<String>(
                      label: const Text("Import format"),
                      onSelected: (newValue) {
                        // newValue can't be null
                        context.read<OnboardingImportBloc>().add(ImportFormatChanged(importFormat: newValue!));
                      },

                      initialSelection: ImportFormat.segwit.name,

                      // value: _selectedValue, // Currently selected value
                      // onChanged: (newValue) {
                      // setState(() {
                      //   _selectedValue = newValue; // Update the selected value
                      // });
                      // },
                      dropdownMenuEntries: [
                        DropdownMenuEntry<String>(
                          value: ImportFormat.segwit.name,
                          label: ImportFormat.segwit.description,
                        ),
                        // DropdownMenuEntry<String>(
                        //   value: ImportFormat.legacy.name,
                        //   label: ImportFormat.legacy.description,
                        // ),
                        DropdownMenuEntry<String>(
                          value: ImportFormat.freewalletBech32.name,
                          label: ImportFormat.freewalletBech32.description,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // _state.getAddressesState is GetAddressesStateError ? Text(_state.getAddressesState.message) : const Text(""),
                // _state.getAddressesState is GetAddressesStateSuccess
                //     ? AddressListView(
                //         addresses: _state.getAddressesState.addresses,
                //         isCheckedMap: _state.isCheckedMap,
                //         onCheckedChanged: (address, checked) {
                //           context.read<OnboardingImportBloc>().add(AddressMapChanged(address: address, isChecked: checked));
                //         },
                //       )
                //     : const Text("")
              ])),
              _state.importState is ImportStateError ? Text(_state.importState.message) : const Text(""),
              Row(children: [
                // TODO: figure out how to disable a button
                ElevatedButton(
                  onPressed: () {
                    context.read<OnboardingImportBloc>().add(ImportWallet());
                  },
                  child: const Text('Import Addresses'),
                ),
              ]),
              _state.importState is ImportStateLoading ? CircularProgressIndicator() : const Text("")
            ],
          )),
    );
  }
}

class AddressListView extends StatelessWidget {
  final List<Address> addresses;
  final Map<Address, bool> isCheckedMap;
  final void Function(Address, bool) onCheckedChanged;

  const AddressListView({
    Key? key,
    required this.addresses,
    required this.isCheckedMap,
    required this.onCheckedChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: ListView.builder(
          shrinkWrap: true,
          // physics: const NeverScrollableScrollPhysics(),
          itemCount: addresses.length,
          itemBuilder: (context, index) {
            final address = addresses[index];
            return AddressListItem(
              address: address,
              isChecked: isCheckedMap[address] ?? false,
              onCheckedChanged: (isChecked) {
                onCheckedChanged(address, isChecked);
              },
            );
          },
        ),
      ),
    );
  }
}

class AddressListItem extends StatelessWidget {
  final Address address;
  final bool isChecked;
  final ValueChanged<bool> onCheckedChanged;

  const AddressListItem({
    Key? key,
    required this.address,
    required this.isChecked,
    required this.onCheckedChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: isChecked,
        onChanged: (value) {
          onCheckedChanged(value!);
        },
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              address.address,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      // subtitle: Text(address.derivationPath),
    );
  }
}
