import 'package:flutter/material.dart';
import 'package:uniparty/components/wallet_pages/balance_total.dart';
import 'package:uniparty/components/wallet_pages/single_wallet_node.dart';
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/wallet_recovery/recover_wallet.dart';

class WalletContainer extends StatelessWidget {
  final String network;
  const WalletContainer({required this.network, super.key});

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    // placeholder
    String? seedHex = 'seedHex';
    String? walletType = 'walletType';
    List<WalletNode> walletNodes = recoverWallet(context, network, seedHex, walletType);

    return Scaffold(
      body: Container(
          margin: EdgeInsets.symmetric(horizontal: screenSize.width / 10, vertical: screenSize.width / 20),
          height: screenSize.height,
          decoration: BoxDecoration(
            border: Border.all(color: const Color.fromRGBO(159, 194, 244, 1.0)),
            color: const Color.fromRGBO(27, 27, 37, 1.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: screenSize.height,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: walletNodes.length,
                    itemBuilder: (BuildContext context, int index) {
                      return SingleWalletNode(
                        walletNode: walletNodes[index],
                        containerSize: screenSize,
                      );
                    },
                  ),
                ),
              ),
              Container(
                width: screenSize.width / 5,
                decoration: const BoxDecoration(
                  border: Border.symmetric(vertical: BorderSide(width: 1, color: Color.fromRGBO(59, 59, 66, 1.0))),
                  color: Color.fromRGBO(27, 27, 37, 1.0),
                ),
                child: const Column(
                  children: [
                    BalanceTotal(),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
