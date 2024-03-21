import 'package:flutter/material.dart';
import 'package:uniparty/components/wallet_pages/single_wallet_node.dart';
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/wallet_recovery/recover_wallet.dart';

class WalletContainer extends StatelessWidget {
  final String network;
  const WalletContainer({required this.network, super.key});

  Future<List<WalletNode>> _loadData(context) async {
    List<WalletNode> walletNodes = [];
    try {
      walletNodes = await recoverWallet(context, network);
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
                ? Scaffold(
                    body: Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: screenSize.width / 10, vertical: screenSize.width / 20),
                      height: screenSize.height,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color.fromRGBO(159, 194, 244, 1.0)),
                        color: const Color.fromRGBO(27, 27, 37, 1.0),
                      ),
                      child: ListView(
                        // This next line does the trick.
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...(snapshot.data as List<WalletNode>)
                              .map((WalletNode walletNode) => SingleWalletNode(
                                    walletNode: walletNode,
                                    containerSize: screenSize,
                                  ))
                        ],
                      ),
                    ),
                  )
                : const Center(
                    // render the loading indicator
                    child: Text('Loading...'),
                  )));
  }
}
