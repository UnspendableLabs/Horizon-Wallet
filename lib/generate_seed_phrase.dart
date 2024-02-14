import 'package:flutter/material.dart';

class GenerateSeedPhrase extends StatelessWidget {
  const GenerateSeedPhrase({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: generate seed phrase https://github.com/dart-bitcoin/bip39
    return const Scaffold(
      body: Center(
        child: Text('Generated seed phrase'),
      ),
    );
  }
}
