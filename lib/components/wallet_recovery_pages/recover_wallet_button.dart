import 'package:flutter/material.dart';
import 'package:uniparty/components/wallet_recovery_pages/recover_wallet_dialog.dart';

class RecoverWalletButton extends StatelessWidget {
  const RecoverWalletButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => const RecoverWalletDialog(),
        );
      },
      style: _buttonStyle(),
      child: const Text('Recover Wallet'),
    );
  }

  ButtonStyle _buttonStyle() {
    return ButtonStyle(
        fixedSize: MaterialStateProperty.all<Size?>(const Size(150.0, 50.0)),
        textStyle: MaterialStateProperty.all<TextStyle?>(const TextStyle(fontSize: 15)));
  }
}
