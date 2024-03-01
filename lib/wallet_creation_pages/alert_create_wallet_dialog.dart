import 'package:counterparty_wallet/common/back_button.dart';
import 'package:counterparty_wallet/secure_utils/bip39.dart';
import 'package:counterparty_wallet/secure_utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AlertCreateWalletDialog extends StatelessWidget {
  final String mnemonic;

  const AlertCreateWalletDialog({required this.mnemonic, super.key});

  // TODO: move to shared
  Future<void> createAndStoreSeedHex(mnemonic) async {
    String seed = Bip39().mnemonicToSeedHex(mnemonic);
    await SecureStorage().writeSecureData(
      'seed_hex',
      seed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Have you written down your seed phrase?'),
        content: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CommonBackButton(),
              SelectableText(mnemonic),
              FilledButton(
                  onPressed: () async {
                    await createAndStoreSeedHex(mnemonic);
                    // TODO: we will want a loading page here
                    // TODO: fetch data
                    // ignore: use_build_context_synchronously
                    GoRouter.of(context).go('/wallet');
                  },
                  child: const Text('Create wallet'))
            ],
          ),
        ));
  }
}
