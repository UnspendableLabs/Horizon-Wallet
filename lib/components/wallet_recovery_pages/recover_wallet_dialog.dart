import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:uniparty/components/common/back_button.dart';
import 'package:uniparty/models/constants.dart';
import 'package:uniparty/models/wallet_retrieve_info.dart';
import 'package:uniparty/redux/app_store.dart';
import 'package:uniparty/redux/models/wallet_retrieve_info_view.dart';
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
    return StoreConnector<AppState, WalletRetrieveInfoViewModel>(
        converter: ((store) => WalletRetrieveInfoViewModel.fromStore(store)),
        builder: (context, viewModel) {
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
                          print('VIEWMODEL: $viewModel');
                          if (_formKey.currentState!.validate()) {
                            WalletRetrieveInfo walletInfo = getSeedHexAndWalletType(
                                _textFieldController.text, dropdownRecoveryWallet);
                            await viewModel.saveInfo(walletInfo.seedHex, walletInfo.walletType);
                            // viewModel.saveToState(walletInfo.seedHex, walletInfo.walletType);
                            // store.dispatch(WalletRetreiveInfoSaveAction(
                            //     walletInfo.seedHex, walletInfo.walletType));
                            print('here?');
                            // ignore: use_build_context_synchronously
                            GoRouter.of(context).go('/wallet');
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
        });
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
