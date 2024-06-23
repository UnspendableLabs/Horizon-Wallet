// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/presentation/screens/onboarding/bloc/onboard_state.dart';
import 'package:horizon/presentation/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:horizon/presentation/screens/onboarding/bloc/onboarding_event.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => OnboardingBloc(), child: _OnboardingScreen());
  }
}

class _OnboardingScreen extends StatefulWidget {
  @override
  State<_OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<_OnboardingScreen> {
  @override
  void initState() {
    context.read<OnboardingBloc>().add(OnboardingInitial());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingSuccessState) {
          GoRouter.of(context).go('/dashboard');
        }
      },
      child: Scaffold(
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
          ),
        ),
      ),
    );
  }
}
