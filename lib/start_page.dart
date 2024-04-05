import 'package:flutter/material.dart';
import 'package:uniparty/components/wallet_pages/wallet.dart';
import 'package:uniparty/components/wallet_recovery_pages/create_and_recover_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPage();
}

class _StartPage extends State<StartPage> {
  // this function is called when the app launches
  Future<String?> _loadData() async {
    return 'Hello World';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loadData(),
        builder: (BuildContext ctx, AsyncSnapshot<String?> snapshot) {
          if (snapshot.hasData) {
            return const Wallet();
          }
          return const CreateAndRecoverPage();
        });
  }
}
