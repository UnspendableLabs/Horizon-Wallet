import 'package:counterparty_wallet/components/wallet_recovery_pages/recover_wallet_dialog.dart';
import 'package:flutter/material.dart';

class CounterwalletRecoverButton extends StatelessWidget {
  const CounterwalletRecoverButton({super.key});

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
      child: const Text('Recover from Counterwallet'),
    );
  }

  ButtonStyle _buttonStyle() {
    return ButtonStyle(
        fixedSize: MaterialStateProperty.all<Size?>(const Size(75.0, 50.0)),
        textStyle: MaterialStateProperty.all<TextStyle?>(
            const TextStyle(fontSize: 15)));
  }
}
