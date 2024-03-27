import 'package:flutter/material.dart';
import 'package:uniparty/components/common/back_button.dart';
import 'package:uniparty/components/wallet_creation_pages/alert_create_wallet_button.dart';

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
              AlertCreateWalletButton(
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
        color: Color.fromRGBO(159, 194, 244, 1.0),
      ),
    );
  }
}
