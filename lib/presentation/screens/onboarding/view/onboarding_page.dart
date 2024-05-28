import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Horizon')),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: () {
              context.go("/onboarding/create");
              // Navigator.pushNamed(context, '/login');
            },
            child: const Text('Create a new wallet'),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              context.go("/onboarding/import");
              // Navigator.pushNamed(context, '/login');
            },
            child: const Text('Import existing'),
          ),
        ],
      )),
    );
  }
}
