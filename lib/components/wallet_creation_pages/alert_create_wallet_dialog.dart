import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:uniparty/components/common/back_button.dart';
import 'package:uniparty/models/constants.dart';
import 'package:uniparty/models/wallet_retrieve_info.dart';
import 'package:uniparty/redux/actions.dart';
import 'package:uniparty/redux/middleware/secure_storage_thunk_middleware.dart';
import 'package:uniparty/wallet_recovery/store_seed_and_wallet_type.dart';

class AlertCreateWalletDialog extends StatelessWidget {
  final String mnemonic;

  const AlertCreateWalletDialog({required this.mnemonic, super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
        converter: ((store) => store.dispatch),
        builder: (context, dispatch) {
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
                          WalletRetrieveInfo walletInfo =
                              getSeedHexAndWalletType(mnemonic, UNIPARTY);
                          await dispatch(
                              saveWalletRetrieveInfo(walletInfo.seedHex, walletInfo.walletType));
                          dispatch(WalletRetreiveInfoSaveAction(
                              walletInfo.seedHex, walletInfo.walletType));

                          // ignore: use_build_context_synchronously
                          GoRouter.of(context).go('/wallet');
                        },
                        child: const Text('Create wallet'))
                  ],
                ),
              ));
        });
  }
}
