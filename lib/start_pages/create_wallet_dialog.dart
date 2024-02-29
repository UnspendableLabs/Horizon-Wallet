import 'package:counterparty_wallet/common/back_button.dart';
import 'package:counterparty_wallet/start_pages/alert_create_wallet_dialog_button.dart';
import 'package:flutter/material.dart';

class CreateWalletDialog extends StatelessWidget {
  final String mnemonic;

  const CreateWalletDialog({required this.mnemonic, super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: _getShape(),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CommonBackButton(),
              SelectableText(mnemonic),
              AlertCreateWalletDialogueButton(
                mnemonic: mnemonic,
              )
            ],
          ),
        ));
  }

  ShapeBorder _getShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
      side: const BorderSide(
        color: Color.fromRGBO(86, 142, 96, 1),
      ),
    );
  }
}
