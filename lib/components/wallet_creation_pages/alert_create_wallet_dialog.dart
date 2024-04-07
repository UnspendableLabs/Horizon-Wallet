import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/bloc/data_events.dart';
import 'package:uniparty/bloc/data_bloc.dart';
import 'package:uniparty/bloc/data_state.dart';
import 'package:uniparty/components/common/back_button.dart';
import 'package:uniparty/components/wallet_pages/wallet.dart';
import 'package:uniparty/models/constants.dart';
import 'package:uniparty/models/wallet_retrieve_info.dart';
import 'package:uniparty/wallet_recovery/store_seed_and_wallet_type.dart';

class AlertCreateWalletDialog extends StatelessWidget {
  final String mnemonic;

  const AlertCreateWalletDialog({required this.mnemonic, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => DataBloc(),
        child: BlocBuilder<DataBloc, DataState>(builder: (context, state) {
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
                          WalletRetrieveInfo walletInfo = getSeedHexAndWalletType(mnemonic, UNIPARTY);
                          print('WALLETINFO $walletInfo');
                          BlocProvider.of<DataBloc>(context).add(SetDataEvent(walletRetrieveInfo: walletInfo));

                          Navigator.push(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(builder: (context) => const Wallet()),
                          );
                        },
                        child: const Text('Create wallet'))
                  ],
                ),
              ));
        }));
  }
}
