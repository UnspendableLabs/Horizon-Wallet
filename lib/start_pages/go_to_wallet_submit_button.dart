import 'package:counterparty_wallet/secure_utils/bip39.dart';
import 'package:counterparty_wallet/secure_utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GoToWalletSubmitButton extends StatelessWidget {
  final String mnemonic;
  final String submitText;

  const GoToWalletSubmitButton(
      {required this.mnemonic, required this.submitText, super.key});

  Future<void> createAndStoreSeedHex(mnemonic) async {
    String seed = Bip39().mnemonicToSeedHex(mnemonic);
    print('seed: $seed');
    await SecureStorage().writeSecureData(
      'seed_hex',
      seed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
        onPressed: () async {
          await createAndStoreSeedHex(mnemonic);
          // TODO: we will want a loading page here
          // ignore: use_build_context_synchronously
          GoRouter.of(context).go('/wallet');
        },
        child: Text(submitText));
  }
}
