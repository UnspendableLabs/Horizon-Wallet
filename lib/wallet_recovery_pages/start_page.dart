import 'package:counterparty_wallet/wallet_creation_pages/create_wallet_button.dart';
import 'package:counterparty_wallet/wallet_recovery_pages/recover_wallet_button.dart';
import 'package:flutter/material.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 250,
          padding: const EdgeInsets.symmetric(vertical: 50.0),
          child: const Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[CreateWalletButton(), RecoverWalletButton()]),
        ),
      ),
    );
  }
}
