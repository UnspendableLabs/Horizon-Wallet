import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import "package:horizon/api/v2_api.dart" as v2_api;
import 'package:horizon/api/v2_api.dart';

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
    final dio = Dio();
    final client = v2_api.V2Api(dio);
    // debugger(when: true);

    final xcpBalances = await client.getBalancesByAddress(widget.address, true);
    // debugger(when: true);

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
          return Container(
            width: screenWidth - 300,

            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // This spreads out the children across the main axis

              children: balances.isEmpty
                  ? [Text('no balance')]
                  : balances!.map<Widget>((balance) => Text('${balance.asset}: ${balance.quantity} ')).toList(),
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
