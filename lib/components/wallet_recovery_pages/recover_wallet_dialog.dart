import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uniparty/components/common/back_button.dart';
import 'package:uniparty/models/wallet_type_enum.dart';
import 'package:uniparty/secure_utils/bip39.dart';
import 'package:uniparty/secure_utils/mnemonic_words.dart';

class RecoverWalletDialog extends StatefulWidget {
  const RecoverWalletDialog({super.key});

  @override
  State<RecoverWalletDialog> createState() => _RecoverWalletPageState();
}

const List<String> list = <String>['counterwallet', 'freewallet', 'uniparty'];
const invalidLengthError = 'seed phrase contains the wrong number of letters';
const invalidWordsError = 'some words are not in the word list';
const invalidNullPhrase = 'seed phrase may not be null';

class _RecoverWalletPageState extends State<RecoverWalletDialog> {
  final _textFieldController = TextEditingController();
  String dropdownValue = list.first;
  final _formKey = GlobalKey<FormState>();
  String? mnemonicError;

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: _getShape(),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // Add TextFormFields and ElevatedButton here.

              const CommonBackButton(),
              TextFormField(
                controller: _textFieldController,
                decoration: const InputDecoration(hintText: "input seed phrase"),
                validator: (value) {
                  if (value == null) {
                    throw ArgumentError(invalidNullPhrase);
                  }
                  try {
                    if (dropdownValue == FREEWALLET || dropdownValue == UNIPARTY) {
                      /*
                      bip39 mnemonicToEntropy will throw if
                      1. a word is not in the word list
                      2. there is a wrong number of words
                      3. entropy is invalid
                      3. the checksum fails
                      */
                      Bip39().mnemonicToEntropy(value);
                    } else if (dropdownValue == COUNTERWALLET) {
                      if (value.split(" ").length != 12) {
                        throw ArgumentError(invalidLengthError);
                      }
                      for (var word in value.split(" ")) {
                        if (!legacyMnemonicWords.contains(word)) {
                          throw ArgumentError(invalidWordsError);
                        }
                      }
                    }
                    return null;
                  } catch (error) {
                    if (error is ArgumentError) {
                      // argument error is thrown by bip39 for invaled phrases
                      return error.message;
                    }
                    if (error is StateError) {
                      // state error is thrown by bip39 for invalid entropy or checksum fails
                      return error.message;
                    }
                    rethrow;
                  }
                },
              ),
              FilledButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      print('HELLOE $mnemonicError');
                    }
                    // ignore: use_build_context_synchronously
                    GoRouter.of(context).go('/wallet');
                  },
                  child: const Text('Recover wallet')),
              DropdownButton<String>(
                value: dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.green),
                underline: Container(
                  height: 2,
                  color: Colors.green,
                ),
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    dropdownValue = value!;
                  });
                },
                items: list.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              )
            ],
          ),
        ));
  }

  ShapeBorder _getShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
      side: const BorderSide(
        color: Color.fromRGBO(86, 142, 96, 1),
      ),
    );
  }
}
