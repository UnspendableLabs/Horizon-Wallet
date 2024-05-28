import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/counterparty_api/counterparty_api.dart';
import 'package:horizon/counterparty_api/models/balance.dart';
import 'package:horizon/services/blockcypher.dart';

class BalanceDisplay extends StatefulWidget {
  final String address;
  // final NetworkEnum network;
  const BalanceDisplay({required this.address, super.key});

  @override
  State<BalanceDisplay> createState() => _BalanceDisplayState();
}

class _BalanceDisplayState extends State<BalanceDisplay> {
  _BalanceDisplayState();

  Future<List<Balance>> _fetchBalances() async {
    final CounterpartyApi counterpartyApi = GetIt.I.get<CounterpartyApi>();
    final BlockCypherService blockCypherService = GetIt.I.get<BlockCypherService>();

    final xcpBalances = await counterpartyApi.fetchBalance(widget.address, NetworkEnum.testnet);
    final btcBalances = await blockCypherService.fetchBalance(widget.address, NetworkEnum.testnet);

    return xcpBalances + btcBalances;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: _fetchBalances(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Balance> balances = snapshot.data as List<Balance>;
          if (balances.isEmpty) {
            // return Row(
            //   mainAxisSize: MainAxisSize.min,
            //   children: <Widget>[
            //     ...AssetEnum.values
            //         .map((asset) => Text('${asset.name}: 0 ', style: const TextStyle(fontSize: 15, color: Colors.grey)))
            //   ],
            // );
          }
          return Container(
            padding: const EdgeInsets.fromLTRB(50, 80, 50, 10),
            child: Container(
              width: screenWidth - 300,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1.5, color: Colors.grey),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // This spreads out the children across the main axis

                children: snapshot.data.map<Widget>((balance) => Text('${balance.asset}: ${balance.quantity} ')).toList(),
              ),
            ),
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
