import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uniparty/components/common/back_button.dart';
import 'package:uniparty/models/wallet_types.dart';
import 'package:uniparty/utils/seed_phrase_validation.dart';

class RecoverWalletDialog extends StatefulWidget {
  const RecoverWalletDialog({super.key});

  @override
  State<RecoverWalletDialog> createState() => _RecoverWalletPageState();
}

const List<String> list = <String>[COUNTERWALLET, FREEWALLET, UNIPARTY];

class _RecoverWalletPageState extends State<RecoverWalletDialog> {
  final _textFieldController = TextEditingController();
  String dropdownRecoveryWallet = list.first;
  final _formKey = GlobalKey<FormState>();

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
              const CommonBackButton(),
              TextFormField(
                controller: _textFieldController,
                decoration: const InputDecoration(hintText: "input seed phrase"),
                validator: (value) {
                  return validateSeedPhrase(value, dropdownRecoveryWallet);
                },
              ),
              FilledButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                    }
                    // ignore: use_build_context_synchronously
                    GoRouter.of(context).go('/wallet');
                  },
                  child: const Text('Recover wallet')),
              DropdownButton<String>(
                value: dropdownRecoveryWallet,
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
                    dropdownRecoveryWallet = value!;
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
