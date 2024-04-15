import 'package:flutter/material.dart';
import 'package:uniparty/widgets/wallet_pages/balance_text.dart';

class BalanceTotal extends StatelessWidget {
  const BalanceTotal({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(style: TextStyle(color: Colors.white, fontSize: 20), 'TOTAL'),
          BalanceText(
            text: 'BTC',
            alignment: Alignment.centerRight,
          ),
          BalanceText(
            text: 'XCP',
            alignment: Alignment.centerRight,
          ),
          BalanceText(
            text: 'rarepepe',
            alignment: Alignment.centerRight,
          )
        ],
      ),
    );
  }
}
