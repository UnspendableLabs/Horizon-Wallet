import 'package:counterparty_wallet/start_pages/create_wallet_dialogue.dart';
import 'package:counterparty_wallet/wallet_pages/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class RecoverWalletButton extends StatelessWidget {
  const RecoverWalletButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => GoRouter.of(context).go('/recover_wallet'),
      style: ButtonStyle(
          fixedSize: MaterialStateProperty.all<Size?>(const Size(150.0, 60.0)),
          textStyle: MaterialStateProperty.all<TextStyle?>(
              const TextStyle(fontSize: 15))),
      child: const Text('Recover Wallet'),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Create storage
  static const storage = FlutterSecureStorage();

// Read value
  Future<String?> getSeedPhrase() async {
    String? value = await storage.read(key: 'seed_phrase');
    print(value);
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
        future: getSeedPhrase(),
        builder: (context, AsyncSnapshot<String?> snapshot) {
          // TODO: verify snapshot data here is coming through as expected
          if (!snapshot.hasData) {
            return const WalletStartPage();
          } else {
            return const WalletPage();
          }
        });
  }
}

class WalletStartPage extends StatelessWidget {
  const WalletStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 250,
          padding: const EdgeInsets.symmetric(vertical: 50.0),
          child: const Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CreateWalletDialogueButton(),
                RecoverWalletButton()
              ]),
        ),
      ),
    );
  }
}
