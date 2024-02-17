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
          builder: (BuildContext context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
                side: const BorderSide(
                  color: Color.fromRGBO(86, 142, 96, 1),
                ),
              ),
              child: Padding(
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
                    
                  ],
                ),
              )),
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
