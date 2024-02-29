import 'package:counterparty_wallet/start_pages/recover_wallet_dialog.dart';
import 'package:flutter/material.dart';

// Define a custom Form widget.
class RecoverWalletDialogButton extends StatelessWidget {
  const RecoverWalletDialogButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => const RecoverWalletDialog(),
        );
      },
      style: ButtonStyle(
          fixedSize: MaterialStateProperty.all<Size?>(const Size(150.0, 50.0)),
          textStyle: MaterialStateProperty.all<TextStyle?>(
              const TextStyle(fontSize: 15))),
      child: const Text('Recover Wallet'),
    );
  }
}
