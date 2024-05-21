import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:uniparty/domain/entities/address.dart';

import 'package:uniparty/presentation/screens/onboarding_import/bloc/onboarding_import_bloc.dart';
import 'package:uniparty/presentation/screens/onboarding_import/bloc/onboarding_import_event.dart';
import 'package:uniparty/presentation/screens/onboarding_import/bloc/onboarding_import_state.dart';

class OnboardingImportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => OnboardingImportBloc(),
        child: const OnboardingImportPage_());
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
  final TextEditingController _seedPhraseController =
      TextEditingController(text: "");
  final TextEditingController _importFormat =
      TextEditingController(text: ImportFormat.segwit.name);
  final Map<Address, bool> _isCheckedMap = {};

  @override
  dispose() {
    _seedPhraseController.dispose();
    _importFormat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingImportBloc, OnboardingImportState>(
        builder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Uniparty')),
        body: Container(
            margin: EdgeInsets.fromLTRB(
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
                      context
                          .read<OnboardingImportBloc>()
                          .add(MnemonicChanged(mnemonic: value));
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Seed phrase',
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      DropdownMenu<String>(
                        label: Text("Import format"),
                        onSelected: (newValue) {
                          // newValue can't be null
                          context.read<OnboardingImportBloc>().add(
                              ImportFormatChanged(importFormat: newValue!));
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
                  state.getAddressesState is GetAddressesStateError
                      ? Text(state.getAddressesState.message)
                      : const Text(""),
                  state.getAddressesState is GetAddressesStateSuccess
                      ? AddressListView(
                          addresses: state.getAddressesState.addresses,
                          isCheckedMap: _isCheckedMap,
                          onCheckedChanged: (address, checked) {
                            print("address");
                            print(address);
                            print("checked");
                            print(checked);

                            setState(() {
                              _isCheckedMap[address] = checked;
                            });
                          },
                        )
                      : const Text("")
                ])),
                Row(children: [
                  ElevatedButton(
                    onPressed: () {
                      // context.go("/onboarding/create");
                      // Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Import'),
                  ),
                ])
              ],
            )),
      );
    });
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
    return SingleChildScrollView(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
      subtitle: Text(address.derivationPath),
    );
  }
}
