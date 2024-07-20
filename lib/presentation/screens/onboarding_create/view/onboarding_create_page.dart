import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_event.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_state.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class OnboardingCreateScreen extends StatelessWidget {
  const OnboardingCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => OnboardingCreateBloc(),
        child: const OnboardingCreatePage_());
  }
}

class OnboardingCreatePage_ extends StatefulWidget {
  const OnboardingCreatePage_({super.key});
  @override
  _OnboardingCreatePageState createState() => _OnboardingCreatePageState();
}

class _OnboardingCreatePageState extends State<OnboardingCreatePage_> {
  final TextEditingController _passwordController =
      TextEditingController(text: "");
  final TextEditingController _passwordConfirmationController =
      TextEditingController(text: "");

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
          final shell = context.read<ShellStateCubit>();
          // reload shell to trigger redirect
          shell.initialize();
        }
      },
      child: BlocBuilder<OnboardingCreateBloc, OnboardingCreateState>(
          builder: (context, state) {
        return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Horizon',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
            ),
            body: switch (state.createState) {
              CreateStateNotAsked => const Mnemonic(),
              CreateStateMnemonicUnconfirmed => ConfirmSeedInputFields(
                  mnemonicErrorState: state.mnemonicError,
                ),
              CreateStateMnemonicConfirmed => PasswordPrompt(
                  passwordController: _passwordController,
                  passwordConfirmationController:
                      _passwordConfirmationController,
                  state: state,
                ),
              Object() => const Text(''),
              null => throw UnimplementedError(),
            });
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
          const Row(children: [
            Text('Password', style: TextStyle(fontSize: 16)),
            Tooltip(
              message: 'Password to encrypt your wallet',
              child: Icon(Icons.info, size: 16),
            ),
          ]),
          Expanded(
            child: Column(
              children: [
                TextField(
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  onChanged: (value) {
                    context
                        .read<OnboardingCreateBloc>()
                        .add(PasswordChanged(password: value));
                  },
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  controller: _passwordConfirmationController,
                  onChanged: (value) {
                    context.read<OnboardingCreateBloc>().add(
                        PasswordConfirmationChanged(
                            passwordConfirmation:
                                _passwordConfirmationController.text));
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Confirm Password',
                  ),
                ),
                _state.passwordError != null
                    ? Text(_state.passwordError!)
                    : const Text(""),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final shell = context.read<ShellStateCubit>();
                            shell.onOnboarding();
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_passwordController.text == '' ||
                                _passwordConfirmationController.text == '') {
                              context.read<OnboardingCreateBloc>().add(
                                  PasswordError(
                                      error: 'Password cannot be empty'));
                            } else if (_passwordController.text !=
                                _passwordConfirmationController.text) {
                              context.read<OnboardingCreateBloc>().add(
                                  PasswordError(
                                      error: 'Passwords do not match'));
                            } else {
                              context
                                  .read<OnboardingCreateBloc>()
                                  .add(CreateWallet(
                                    ));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text('Create Wallet'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Mnemonic extends StatefulWidget {
  const Mnemonic({super.key});

  @override
  State<Mnemonic> createState() => _MnemonicState();
}

class _MnemonicState extends State<Mnemonic> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<OnboardingCreateBloc>(context).add(GenerateMnemonic());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCreateBloc, OnboardingCreateState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            children: [
              if (state.mnemonicState is GenerateMnemonicStateLoading)
                const CircularProgressIndicator()
              else if (state.mnemonicState is GenerateMnemonicStateGenerated)
                SelectableText(
                  state.mnemonicState.mnemonic,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
              const Text(
                'Please write down your seed phrase in a secure location. It is the only way to recover your wallet.',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final shell = context.read<ShellStateCubit>();
                          shell.onOnboarding();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context
                              .read<OnboardingCreateBloc>()
                              .add(UnconfirmMnemonic());
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ConfirmSeedInputFields extends StatefulWidget {
  final String? mnemonicErrorState;
  const ConfirmSeedInputFields({required this.mnemonicErrorState, super.key});
  @override
  State<ConfirmSeedInputFields> createState() => _ConfirmSeedInputFieldsState();
}

class _ConfirmSeedInputFieldsState extends State<ConfirmSeedInputFields> {
  List<TextEditingController> controllers =
      List.generate(12, (_) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(12, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Please confirm your seed phrase',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (columnIndex) {
                      return Expanded(
                        child: Column(
                          children: List.generate(4, (rowIndex) {
                            int index = columnIndex * 4 + rowIndex;
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Text("${index + 1}. ",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Expanded(
                                    child: TextField(
                                      controller: controllers[index],
                                      focusNode: focusNodes[index],
                                      onChanged: (value) =>
                                          handleInput(value, index),
                                      decoration: InputDecoration(
                                        labelText: 'Word ${index + 1}',
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                  widget.mnemonicErrorState != null
                      ? Text(widget.mnemonicErrorState!)
                      : const Text(""),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context
                        .read<OnboardingCreateBloc>()
                        .add(GoBackToMnemonic()),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context
                          .read<OnboardingCreateBloc>()
                          .add(ConfirmMnemonic(
                              mnemonic: controllers
                                  .map((controller) => controller.text)
                                  .join(' ')
                                  .trim()));
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void handleInput(String value, int index) {
    var words = value.split(RegExp(r'\s+'));
    if (words.length > 1 && index < 11) {
      for (int i = 0; i < words.length && (index + i) < 12; i++) {
        controllers[index + i].text = words[i];
        if ((index + i + 1) < 12) {
          FocusScope.of(context).requestFocus(focusNodes[index + i + 1]);
        }
      }
    }
    updateMnemonic();
  }

  void updateMnemonic() {
    String mnemonic =
        controllers.map((controller) => controller.text).join(' ').trim();
    context
        .read<OnboardingCreateBloc>()
        .add(ConfirmMnemonicChanged(mnemonic: mnemonic));
  }
}
