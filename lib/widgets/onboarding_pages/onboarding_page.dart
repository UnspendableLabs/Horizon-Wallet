import 'package:flutter/material.dart';
import 'package:horizon/widgets/onboarding_pages/onboarding_stateful_widget.dart';

class OnboardingPageWrapper extends StatelessWidget {
  const OnboardingPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 250,
          padding: const EdgeInsets.symmetric(vertical: 50.0),
          child: const OnboardingPage(),
        ),
      ),
    );
  }
}
