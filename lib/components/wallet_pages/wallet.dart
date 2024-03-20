import 'package:flutter/material.dart';
import 'package:uniparty/components/wallet_pages/wallet_container.dart';
import 'package:uniparty/models/wallet_node.dart';
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
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
        body: FutureBuilder(
            future: _loadData(context),
            builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) => snapshot.hasData
                ? SizedBox(
                    height: screenSize.height,
                    // padding: const EdgeInsets.symmetric(vertical: 50.0),
                    child: WalletContainer(snapshotData: snapshot.data),
                  )
                : const Center(
                    // render the loading indicator
                    child: Text('Loading...'),
                  )));
  }
}
