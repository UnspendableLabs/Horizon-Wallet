import 'package:flutter/material.dart';

class OnboardingCreateScreen extends StatelessWidget {
  const OnboardingCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uniparty')),
      body: Center(
          child: Text(
        "TODO: generate seed, prompt user to save",
      )),
    );
  }
}
