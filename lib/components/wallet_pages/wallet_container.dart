import 'package:flutter/material.dart';
import 'package:uniparty/components/wallet_pages/single_wallet_node.dart';
import 'package:uniparty/models/wallet_node.dart';

class WalletContainer extends StatelessWidget {
  List<dynamic>? snapshotData;

  WalletContainer({required this.snapshotData, super.key});

  @override
  Widget build(BuildContext context) {
    if (snapshotData == null) {
      return const Center(
        // render the loading indicator
        child: CircularProgressIndicator(),
      );
    }
    var containerSize = MediaQuery.of(context).size;

    List<WalletNode> walletNodes = snapshotData as List<WalletNode>;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UNIPARTY',
          style: TextStyle(color: Colors.white, fontSize: 40, overflow: TextOverflow.visible),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        margin: EdgeInsets.symmetric(
            horizontal: containerSize.width / 10, vertical: containerSize.width / 20),
        height: containerSize.height,
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromRGBO(159, 194, 244, 1.0)),
          color: const Color.fromRGBO(27, 27, 37, 1.0),
        ),
        child: ListView(
          // This next line does the trick.
          scrollDirection: Axis.horizontal,
          children: [
            ...walletNodes.map((WalletNode walletNode) => SingleWalletNode(
                  walletNode: walletNode,
                  containerSize: containerSize,
                ))
          ],
        ),
      ),
    );
  }
}
