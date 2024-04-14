import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/app_router.dart';
import 'package:uniparty/bitcoin_wallet_utils/bip39.dart';
import 'package:uniparty/bloc/stored_wallet_data_bloc.dart';
import 'package:uniparty/components/common/back_button.dart';
import 'package:uniparty/models/constants.dart';
import 'package:uniparty/models/stored_wallet_data.dart';
import 'package:uniparty/wallet_recovery/get_seed_and_wallet_type.dart';

class CreateWalletFlow extends StatelessWidget {
  const CreateWalletFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: _buttonStyle(),
        child: const Text('Create Wallet'),
        onPressed: () {
          final mnemonic = GetIt.I.get<Bip39Service>().generateMnemonic();

          showDialog<String>(
              context: context,
              builder: (BuildContext context) => BlocProvider(
                  create: (context) => StoredWalletDataBloc(),
                  child: BlocBuilder<StoredWalletDataBloc, StoredWalletDataState>(builder: (context, state) {
                    return CreateWalletDialog(mnemonic: mnemonic);
                  })));
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
        shape: _getShape(),
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
                  StoredWalletData walletData = getSeedHexAndWalletType(widget.mnemonic, UNIPARTY);
                  BlocProvider.of<StoredWalletDataBloc>(context).add(WriteStoredWalletDataEvent(data: walletData));

                  // await Future.delayed(const Duration(milliseconds: 500));
                  Navigator.pushNamed(
                    // ignore: use_build_context_synchronously
                    context,
                    AppRouter.walletPage,
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

ShapeBorder _getShape() {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(4.0),
    side: const BorderSide(
      color: Color.fromRGBO(159, 194, 244, 1.0),
    ),
  );
}
