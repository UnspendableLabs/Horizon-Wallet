import 'package:flutter/material.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/counterparty_api/counterparty_api.dart';
import 'package:uniparty/models/wallet_node.dart';

class SingleWalletNode extends StatefulWidget {
  final WalletNode walletNode;
  final Size containerSize;
  final NetworkEnum network;
  const SingleWalletNode({required this.walletNode, required this.containerSize, required this.network, super.key});

  @override
  State<SingleWalletNode> createState() => _SingleWalletNode();
}

class _SingleWalletNode extends State<SingleWalletNode> {
  final CounterpartyApi counterpartyApi = CounterpartyApi();
  Future<String> _fetchBalance() async {
    // final obj = await counterpartyApi.fetchBalance(widget.walletNode.address, widget.network);
    // print('balance $obj');
    // return obj.toString();
    return 'balance';
  }

  //  balance = await counterpartyApi.fetchBalance(address, network)
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: _fetchBalance(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('ERROR: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const Text('Loading...');
          }
          return Container(
            decoration: const BoxDecoration(
                border: Border.symmetric(vertical: BorderSide(width: 0.5, color: Color.fromRGBO(59, 59, 66, 1.0)))),
            width: widget.containerSize.width / 5,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                      style: const TextStyle(color: Colors.white, fontSize: 20, overflow: TextOverflow.visible),
                      '${_getAddressPrefix(widget.walletNode.address)} Address ${widget.walletNode.index + 1}'),
                  Text(
                    style: const TextStyle(color: Color.fromRGBO(159, 194, 244, 1.0)),
                    widget.walletNode.address,
                    overflow: TextOverflow.ellipsis,
                  ) // TODO: use BalanceText widget and display balances
                ],
              ),
            ),
          );
        });
  }

  String _getAddressPrefix(String address) {
    if (address.startsWith('bc1q') || address.startsWith('tb1')) {
      return 'Segwit';
    }
    return 'Legacy';
  }
}
