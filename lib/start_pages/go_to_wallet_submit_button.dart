import 'package:counterparty_wallet/secure_utils/create_wallet_util.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GoToWalletSubmitButton extends StatelessWidget {
  final String mnemonic;
  final String submitText;

  const GoToWalletSubmitButton(
      {required this.mnemonic, required this.submitText, super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
        onPressed: () async {
          await createAddress(mnemonic);
          // TODO: generate pub/private key
          // TODO: get balances
          // ignore: use_build_context_synchronously
          GoRouter.of(context).go('/wallet');
        },
        child: Text(submitText));
  }
}
