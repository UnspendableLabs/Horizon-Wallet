import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      onPressed: () {
        final mnemonic = Bip39().generateMnemonic();

        showDialog<String>(
            context: context,
            builder: (BuildContext context) => Dialog(
                shape: _getShape(),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const CommonBackButton(),
                      SelectableText(mnemonic),
                      FilledButton(
                        onPressed: () {
                          showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => BlocProvider(
                                  create: (context) => StoredWalletDataBloc(),
                                  child: BlocBuilder<StoredWalletDataBloc, StoredWalletDataState>(builder: (context, state) {
                                    return AlertDialog(
                                        title: const Text('Have you written down your seed phrase?'),
                                        content: Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              const CommonBackButton(),
                                              SelectableText(mnemonic),
                                              FilledButton(
                                                  onPressed: () async {
                                                    StoredWalletData walletData =
                                                        getSeedHexAndWalletType(mnemonic, UNIPARTY);

                                                    BlocProvider.of<StoredWalletDataBloc>(context)
                                                        .add(WriteStoredWalletDataEvent(data: walletData));

                                                    // await Future.delayed(const Duration(milliseconds: 500));

                                                    Navigator.pushNamed(
                                                      // ignore: use_build_context_synchronously
                                                      context,
                                                      AppRouter.walletPage,
                                                    );
                                                  },
                                                  child: const Text('Create wallet'))
                                            ],
                                          ),
                                        ));
                                  })));
                        },
                        child: const Text('Create Wallet'),
                      )
                    ],
                  ),
                )));
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

  ShapeBorder _getShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
      side: const BorderSide(
        color: Color.fromRGBO(159, 194, 244, 1.0),
      ),
    );
  }
}
