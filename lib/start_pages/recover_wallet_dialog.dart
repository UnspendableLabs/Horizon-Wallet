import 'package:counterparty_wallet/common/back_button.dart';
import 'package:counterparty_wallet/secure_utils/bip39.dart';
import 'package:counterparty_wallet/secure_utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecoverWalletDialog extends StatefulWidget {
  const RecoverWalletDialog({super.key});

  @override
  State<RecoverWalletDialog> createState() => _RecoverWalletPageState();
}

class _RecoverWalletPageState extends State<RecoverWalletDialog> {
  final _textFieldController = TextEditingController();

  // TODO: move to shared
  Future<void> createAndStoreSeedHex(mnemonic) async {
    String seed = Bip39().mnemonicToSeedHex(mnemonic);
    await SecureStorage().writeSecureData(
      'seed_hex',
      seed,
    );
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: _getShape(),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CommonBackButton(),
              TextField(
                controller: _textFieldController,
                decoration:
                    const InputDecoration(hintText: "input seed phrase"),
              ),
              // TODO: any validation on the seed phrase?
              FilledButton(
                  onPressed: () async {
                    await createAndStoreSeedHex(_textFieldController.text);
                    // TODO: we will want a loading page here
                    // TODO: fetch data
                    // ignore: use_build_context_synchronously
                    GoRouter.of(context).go('/wallet');
                  },
                  child: const Text('Recover wallet'))
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
