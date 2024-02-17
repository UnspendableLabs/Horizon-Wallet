import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/material.dart';

class CreateWalletDialogueButton extends StatelessWidget {
  const CreateWalletDialogueButton({super.key});

  String generateMnemonic() {
    return bip39.generateMnemonic(); // Generate a new mnemonic phrase
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        final mnemonic = generateMnemonic();

        showDialog<String>(
          context: context,
          builder: (BuildContext context) => Dialog.fullscreen(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(mnemonic),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
      style: ButtonStyle(
          fixedSize: MaterialStateProperty.all<Size?>(const Size(200.0, 75.0)),
          textStyle: MaterialStateProperty.all<TextStyle?>(
              const TextStyle(fontSize: 15))),
      child: const Text('Create Wallet'),
    );
  }
}
