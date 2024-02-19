import 'package:counterparty_wallet/secure_utils/bip39.dart';
import 'package:counterparty_wallet/secure_utils/secure_storage.dart';
import 'package:counterparty_wallet/start_pages/go_to_wallet_submit_button.dart';
import 'package:flutter/material.dart';

class AlertCreateWalletDialogueButton extends StatelessWidget {
  final String mnemonic;

  const AlertCreateWalletDialogueButton({required this.mnemonic, super.key});

  Future<void> createAndStoreSeedHex(mnemonic) async {
    String seed = Bip39().mnemonicToSeedHex(mnemonic);
    await SecureStorage().writeSecureData(
      'seed_hex',
      seed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
              title: const Text('Have you written down your seed phrase?'),
              content: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    BackButton(
                      style: const ButtonStyle(
                          alignment: AlignmentDirectional.topStart),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text(mnemonic),
                    GoToWalletSubmitButton(
                        mnemonic: mnemonic, submitText: 'Create Wallet')
                  ],
                ),
              )),
        );
      },
      child: const Text('Create Wallet'),
    );
  }
}
