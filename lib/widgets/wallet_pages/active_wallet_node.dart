import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/bloc/balance_bloc.dart';
import 'package:uniparty/bloc/network_bloc.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/wallet_node.dart';

class ActiveWalletNode extends StatefulWidget {
  final WalletNode activeWallet;
  final double width;
  final NetworkEnum network;
  const ActiveWalletNode({required this.activeWallet, required this.width, required this.network, super.key});

  @override
  State<ActiveWalletNode> createState() => _ActiveWalletNode();
}

class _ActiveWalletNode extends State<ActiveWalletNode> {
  @override
  void initState() {
    super.initState();
    var network = BlocProvider.of<NetworkBloc>(context).state.network;

    BlocProvider.of<BalanceBloc>(context).add(LoadBalanceEvent(address: widget.activeWallet.address, network: network));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
                style: const TextStyle(color: Colors.white, fontSize: 20, overflow: TextOverflow.visible),
                _getAddressPrefix(widget.activeWallet.address)),
            SelectableText(
              style: const TextStyle(color: Color.fromRGBO(159, 194, 244, 1.0)),
              widget.activeWallet.address,
            ),
            BlocBuilder<BalanceBloc, BalanceState>(builder: (context, balanceState) {
              return switch (balanceState) {
                BalanceInitial() => const Text('balance initial'),
                BalanceLoading() => const Text('balance loading...'),
                BalanceSuccess() => balanceState.balances.isEmpty
                    // TODO: fetch btc and display
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ...AssetEnum.values.map(
                              (asset) => Text('${asset.name}: 0 ', style: const TextStyle(fontSize: 15, color: Colors.grey)))
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ...balanceState.balances.map((balance) => Text('${balance.asset}: ${balance.quantity} ',
                              style: const TextStyle(fontSize: 15, color: Colors.grey)))
                        ],
                      ),
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
