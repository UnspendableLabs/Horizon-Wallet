import 'package:flutter/material.dart';
import 'package:uniparty/models/wallet_node.dart';

class SingleWalletNode extends StatelessWidget {
  final WalletNode walletNode;
  final Size containerSize;

  const SingleWalletNode({required this.walletNode, required this.containerSize, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border.symmetric(
              vertical: BorderSide(width: 0.5, color: Color.fromRGBO(59, 59, 66, 1.0)))),
      width: containerSize.width / 5,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
                style: const TextStyle(
                    color: Colors.white, fontSize: 20, overflow: TextOverflow.visible),
                '${walletNode.address.startsWith('bc1q') ? 'Segwit ' : ''}Address ${walletNode.index + 1}'),
            Text(
              style: const TextStyle(color: Color.fromRGBO(159, 194, 244, 1.0)),
              walletNode.address,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
    );
  }
}
