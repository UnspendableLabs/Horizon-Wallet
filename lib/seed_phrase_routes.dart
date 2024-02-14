import 'package:counterparty_wallet/generate_seed_phrase.dart';
import 'package:flutter/material.dart';

import 'input_seed_phrase.dart';

class InputSeedPhraseButton extends StatelessWidget {
  const InputSeedPhraseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('Input existing seed phrase'),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SeedPhraseInput()),
        );
      },
    );
  }
}

class GenerateSeedPhraseButton extends StatelessWidget {
  const GenerateSeedPhraseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('GenerateSeedPhrase'),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GenerateSeedPhrase()),
        );
      },
    );
  }
}

class SeedPhraseRoute extends StatelessWidget {
  const SeedPhraseRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [InputSeedPhraseButton(), GenerateSeedPhraseButton()],
        ),
      ),
    );
  }
}
