import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import "package:horizon/data/sources/network/api/v2_api.dart" as v2_api;
import 'package:horizon/data/sources/network/api/v2_api.dart';

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
    final client = GetIt.I.get<v2_api.V2Api>();

    final xcpBalances = await client.getBalancesByAddress(widget.address, true);
    return xcpBalances.result!;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: _fetchBalances(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Balance> balances = snapshot.data as List<Balance>;
          return SizedBox(
            width: screenWidth - 300,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // This spreads out the children across the main axis

              children: balances.isEmpty
                  ? [const Text('no balance')]
                  : balances
                      .map<Widget>((balance) => Text(
                          '${balance.asset}: ${(balance.quantity / 100000000).toStringAsFixed(8)}'))
                      .toList(),
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
