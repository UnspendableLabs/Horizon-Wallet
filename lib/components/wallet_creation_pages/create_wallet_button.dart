import 'package:flutter/material.dart';
import 'package:uniparty/components/wallet_creation_pages/create_wallet_dialog.dart';
import 'package:uniparty/secure_utils/bip39.dart';

class CreateWalletButton extends StatelessWidget {
  const CreateWalletButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        final mnemonic = Bip39().generateMnemonic();

        showDialog<String>(
            context: context,
            builder: (BuildContext context) => CreateWalletDialog(mnemonic: mnemonic));
      },
      style: _buttonStyle(),
      child: const Text('Create Wallet'),
    );
  }

  ButtonStyle _buttonStyle() {
    return ButtonStyle(
        fixedSize: MaterialStateProperty.all<Size?>(const Size(200.0, 75.0)),
        textStyle: MaterialStateProperty.all<TextStyle?>(const TextStyle(fontSize: 15)));
  }
}
