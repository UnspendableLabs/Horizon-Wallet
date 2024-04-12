import 'package:flutter/material.dart';
import 'package:uniparty/components/onboarding_pages/create_wallet_flow.dart';
import 'package:uniparty/components/onboarding_pages/recover_wallet_flow.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 250,
          padding: const EdgeInsets.symmetric(vertical: 50.0),
          child: const Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[CreateWalletFlow(), RecoverWalletFlow()]),
        ),
      ),
    );
  }
}
