// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_event.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_state.dart';

class OnboardingCreateScreen extends StatelessWidget {
  const OnboardingCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => OnboardingCreateBloc(), child: _OnboardingCreatePage());
  }
}

class _OnboardingCreatePage extends StatefulWidget {
  @override
  State<_OnboardingCreatePage> createState() => _OnboardingCreatePageState();
}

class _OnboardingCreatePageState extends State<_OnboardingCreatePage> {
  final TextEditingController _passwordController = TextEditingController(text: "");
  final TextEditingController _passwordConfirmationController = TextEditingController(text: "");

  @override
  dispose() {
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCreateBloc, OnboardingCreateState>(
      listener: (context, state) {
        if (state.createState is CreateStateSuccess) {
          GoRouter.of(context).go('/dashboard');
        }
      },
      child: BlocBuilder<OnboardingCreateBloc, OnboardingCreateState>(builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Horizon')),
          body: state.password != null
              ? Mnemonic(state: state)
              : PasswordPrompt(
                  passwordController: _passwordController,
                  passwordConfirmationController: _passwordConfirmationController,
                  state: state,
                ),
        );
      }),
    );
  }
}

// Basically a duplicate of import prompt
class PasswordPrompt extends StatelessWidget {
  const PasswordPrompt({
    super.key,
    required TextEditingController passwordController,
    required TextEditingController passwordConfirmationController,
    required OnboardingCreateState state,
  })  : _passwordController = passwordController,
        _passwordConfirmationController = passwordConfirmationController,
        _state = state;

  final TextEditingController _passwordController;
  final TextEditingController _passwordConfirmationController;
  final OnboardingCreateState _state;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordConfirmationController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Confirm Password',
                  ),
                ),
                _state.passwordError != null ? Text(_state.passwordError!) : const Text(""),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.read<OnboardingCreateBloc>().add(
                              PasswordSubmit(
                                password: _passwordController.text,
                                passwordConfirmation: _passwordConfirmationController.text,
                              ),
                            );
                      },
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Mnemonic extends StatelessWidget {
  const Mnemonic({
    super.key,
    required OnboardingCreateState state,
  }) : _state = state;

  final OnboardingCreateState _state;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          children: [
            (_state.mnemonicState is GenerateMnemonicStateLoading
                ? const CircularProgressIndicator()
                : _state.mnemonicState is GenerateMnemonicStateError
                    ? Text("Error: ${_state.mnemonicState.message}")
                    : _state.mnemonicState is GenerateMnemonicStateSuccess
                        ? SelectableText(
                            _state.mnemonicState.mnemonic,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          )
                        : const Text("")),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.read<OnboardingCreateBloc>().add(CreateWallet());
                  },
                  child: const Text('Create Wallet'),
                ),
              ],
            ),
          ],
        ));
  }
}
