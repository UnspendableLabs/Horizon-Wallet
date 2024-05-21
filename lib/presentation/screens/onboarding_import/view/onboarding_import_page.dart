import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final TextEditingController _seedPhraseController = TextEditingController();
  final TextEditingController _importFormat = TextEditingController(text: ImportFormat.segwit.name);

  @override
  dispose() {
    _seedPhraseController.dispose();
    _importFormat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingImportBloc, OnboardingImportState>(
        buildWhen: (previous, current) {
      print("previous: $previous");
      print("curious: $current");

      return previous != current;
    }, builder: (context, state) {
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
                      context.read<OnboardingImportBloc>().add(DeriveAddress(
                          mnemonic: value,
                          importFormat: _importFormat.text ));
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
                              DeriveAddress(
                                  mnemonic: _seedPhraseController.text,
                                  importFormat: newValue!));
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
                  Text(state is NotAsked ? "Initial" : ""),
                  Text(state is Success ? state.address.address : ""),
                  Text(state is Loading ? "Loading" : ""),
                  Text(state is Error ? (state as Error).message : ""),
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
