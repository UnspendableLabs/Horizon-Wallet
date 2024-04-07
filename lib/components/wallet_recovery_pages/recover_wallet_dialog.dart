import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/bloc/data_events.dart';
import 'package:uniparty/bloc/data_bloc.dart';
import 'package:uniparty/bloc/data_state.dart';
import 'package:uniparty/components/common/back_button.dart';
import 'package:uniparty/components/wallet_pages/wallet.dart';
import 'package:uniparty/models/constants.dart';
import 'package:uniparty/models/wallet_retrieve_info.dart';
import 'package:uniparty/utils/seed_phrase_validation.dart';
import 'package:uniparty/wallet_recovery/store_seed_and_wallet_type.dart';

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
    return BlocProvider(
        create: (context) => DataBloc(),
        child: BlocBuilder<DataBloc, DataState>(builder: (context, state) {
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
                          if (_formKey.currentState!.validate()) {
                            WalletRetrieveInfo walletInfo =
                                getSeedHexAndWalletType(_textFieldController.text, dropdownRecoveryWallet);

                            BlocProvider.of<DataBloc>(context).add(SetDataEvent(walletRetrieveInfo: walletInfo));

                            Navigator.push(
                              // ignore: use_build_context_synchronously
                              context,
                              MaterialPageRoute(builder: (context) => const Wallet()),
                            );
                          }
                        },
                        child: const Text('Recover wallet')),
                    DropdownButton<String>(
                      value: dropdownRecoveryWallet,
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      style: const TextStyle(color: Color.fromRGBO(159, 194, 244, 1.0)),
                      underline: Container(
                        height: 2,
                        color: const Color.fromRGBO(159, 194, 244, 1.0),
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
        }));
  }

  ShapeBorder _getShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
      side: const BorderSide(
        color: Color.fromRGBO(159, 194, 244, 1.0),
      ),
    );
  }
}
