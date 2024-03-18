import 'package:flutter/material.dart';
import 'package:uniparty/secure_utils/secure_storage.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 250,
          padding: const EdgeInsets.symmetric(vertical: 50.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
            const Text('Wallet Page'),
            ElevatedButton(
                onPressed: () async {
                  await SecureStorage().deleteAll();
                },
                child: const Text('delete local storage'))
          ]),
        ),
      ),
    );
  }
}
