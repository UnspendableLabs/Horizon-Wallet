import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateWalletPage extends StatelessWidget {
  const CreateWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: generate seed phrase https://github.com/dart-bitcoin/bip39
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.navigate_before),
          tooltip: 'Go back',
          onPressed: () => GoRouter.of(context).go('/'),
        ),
      ),
      body: const Center(
        child: Text('Generated seed phrase'),
      ),
    );
  }
}
