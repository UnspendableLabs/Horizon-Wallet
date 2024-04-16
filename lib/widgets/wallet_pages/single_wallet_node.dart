import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/bloc/balance_bloc.dart';
import 'package:uniparty/bloc/network_bloc.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/wallet_node.dart';

class SingleWalletNode extends StatefulWidget {
  final WalletNode walletNode;
  final double width;
  final NetworkEnum network;
  const SingleWalletNode({required this.walletNode, required this.width, required this.network, super.key});

  @override
  State<SingleWalletNode> createState() => _SingleWalletNode();
}

class _SingleWalletNode extends State<SingleWalletNode> {
  @override
  void initState() {
    super.initState();
    var network = BlocProvider.of<NetworkBloc>(context).state.network;

    BlocProvider.of<BalanceBloc>(context).add(LoadBalanceEvent(address: widget.walletNode.address, network: network));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border.symmetric(vertical: BorderSide(width: 0.5, color: Color.fromRGBO(59, 59, 66, 1.0)))),
      width: widget.width,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
                style: const TextStyle(color: Colors.white, fontSize: 20, overflow: TextOverflow.visible),
                '${_getAddressPrefix(widget.walletNode.address)} Address ${widget.walletNode.index + 1}'),
            SelectableText(
              style: const TextStyle(color: Color.fromRGBO(159, 194, 244, 1.0)),
              widget.walletNode.address,
            ),
            BlocBuilder<BalanceBloc, BalanceState>(builder: (context, balanceState) {
              return switch (balanceState) {
                BalanceInitial() => const Text('balance initial'),
                BalanceLoading() => const Text('balance loading...'),
                BalanceSuccess() => const Text('succees'),
                BalanceError() => Text('balance error: ${balanceState.message}'),
              };
            })
          ],
        ),
      ),
    );
  }

  String _getAddressPrefix(String address) {
    if (address.startsWith('bc1q') || address.startsWith('tb1')) {
      return 'Segwit';
    }
    return 'Legacy';
  }
}
