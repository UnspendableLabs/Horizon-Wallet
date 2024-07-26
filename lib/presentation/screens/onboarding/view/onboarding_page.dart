import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Horizon',
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () {
                final shell = context.read<ShellStateCubit>();

                shell.onOnboardingCreate();
              },
              child: const Text('Create a new wallet'),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                final shell = context.read<ShellStateCubit>();

                shell.onOnboardingImport();
                // Navigator.pushNamed(context, '/login');
              },
              child: const Text('Import existing'),
            ),
          ],
        ),
      ),
    );
  }
}
