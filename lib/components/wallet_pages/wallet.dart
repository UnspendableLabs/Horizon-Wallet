import 'package:flutter/material.dart';
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/utils/secure_storage.dart';
import 'package:uniparty/wallet_recovery/recover_wallet.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  Future<List<WalletNode>> _loadData(context) async {
    List<WalletNode> walletNodes = [];
    try {
      walletNodes = await recoverWallet(context);
    } catch (err) {
      print(err);
    }
    print('WALLET NODES $walletNodes');

    return walletNodes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: _loadData(context),
            builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) => snapshot.hasData
                ? Center(
                    child: Container(
                      height: 250,
                      padding: const EdgeInsets.symmetric(vertical: 50.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const Text('Wallet Page'),
                            ElevatedButton(
                                onPressed: () async {
                                  await SecureStorage().deleteAll();
                                },
                                child: const Text('delete local storage'))
                          ]),
                    ),
                  )
                : const Center(
                    // render the loading indicator
                    child: CircularProgressIndicator(),
                  )));
  }
}
