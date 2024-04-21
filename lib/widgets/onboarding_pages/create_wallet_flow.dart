import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/app_router.dart';
import 'package:uniparty/bitcoin_wallet_utils/seed_utils/bip39.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/create_wallet_payload.dart';
import 'package:uniparty/widgets/common/back_button.dart';
import 'package:uniparty/widgets/common/common_dialog_shape.dart';

class CreateWalletFlow extends StatelessWidget {
  const CreateWalletFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: _buttonStyle(),
        child: const Text('Create Wallet'),
        onPressed: () {
          final mnemonic = GetIt.I.get<Bip39Service>().generateMnemonic();

          showDialog<String>(context: context, builder: (BuildContext context) => CreateWalletDialog(mnemonic: mnemonic));
        });
  }

  ButtonStyle _buttonStyle() {
    return ButtonStyle(
        fixedSize: MaterialStateProperty.all<Size?>(const Size(200.0, 75.0)),
        textStyle: MaterialStateProperty.all<TextStyle?>(const TextStyle(fontSize: 15)));
  }
}

class CreateWalletDialog extends StatefulWidget {
  final String mnemonic;
  const CreateWalletDialog({required this.mnemonic, super.key});

  @override
  State<CreateWalletDialog> createState() => _CreateWalletDialogState();
}

class _CreateWalletDialogState extends State<CreateWalletDialog> {
  int submitClickCount = 0;
  String warning = '';
  _CreateWalletDialogState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: getDialogShape(),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CommonBackButton(),
              SelectableText(widget.mnemonic),
              Text(warning,
                  style: const TextStyle(
                      fontStyle: FontStyle.normal,
                      fontSize: 40,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      wordSpacing: 2.0,
                      height: 1.5,
                      decoration: TextDecoration.none,
                      decorationColor: Colors.red,
                      decorationStyle: TextDecorationStyle.solid,
                      decorationThickness: 1.0,
                      debugLabel: 'red text')),
              FilledButton(
                onPressed: () {
                  if (submitClickCount == 0) {
                    setState(() {
                      submitClickCount = submitClickCount + 1;
                      warning = 'Please write down your seed phrase and store it in a safe place.';
                    });
                    return;
                  }

                  Navigator.pushNamed(
                    context,
                    AppRouter.walletPage,
                    arguments: CreateWalletPayload(mnemonic: widget.mnemonic, recoveryWallet: RecoveryWalletEnum.uniparty),
                  );
                },
                child: const Text('Create Wallet'),
              )
            ],
          ),
        ));
    // });
  }
}


