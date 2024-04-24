import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/counterparty_api/counterparty_api.dart';
import 'package:uniparty/counterparty_api/models/balance.dart';

class SingleAddressDisplay extends StatefulWidget {
  final String address;
  final NetworkEnum network;
  const SingleAddressDisplay({required this.address, required this.network, super.key});

  @override
  State<SingleAddressDisplay> createState() => _SingleAddressDisplayState();
}

class _SingleAddressDisplayState extends State<SingleAddressDisplay> {
  _SingleAddressDisplayState();

  Future<List<Balance>> _fetchBalances() async {
    final CounterpartyApi counterpartyApi = GetIt.I.get<CounterpartyApi>();

    final balances = await counterpartyApi.fetchBalance(widget.address, widget.network);
    return balances;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchBalances(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Balance> balances = snapshot.data as List<Balance>;
          if (balances.isEmpty) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ...AssetEnum.values
                    .map((asset) => Text('${asset.name}: 0 ', style: const TextStyle(fontSize: 15, color: Colors.grey)))
              ],
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ...balances.map((balance) =>
                  Text('${balance.asset}: ${balance.quantity} ', style: const TextStyle(fontSize: 15, color: Colors.grey)))
            ],
          );
        } else if (snapshot.hasError) {
          return Text('balance error: ${snapshot.error}');
        } else {
          return const Text('balance loading...');
        }
      },
    );
  }
}
