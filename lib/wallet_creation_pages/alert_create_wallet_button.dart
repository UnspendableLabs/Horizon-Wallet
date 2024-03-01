import 'package:counterparty_wallet/wallet_creation_pages/alert_create_wallet_dialog.dart';
import 'package:flutter/material.dart';

class AlertCreateWalletButton extends StatelessWidget {
  final String mnemonic;

  const AlertCreateWalletButton({required this.mnemonic, super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        showDialog<String>(
            context: context,
            builder: (BuildContext context) =>
                AlertCreateWalletDialog(mnemonic: mnemonic));
      },
      child: const Text('Create Wallet'),
    );
  }
}
