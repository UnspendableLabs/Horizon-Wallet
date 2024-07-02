import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_event.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_state.dart';

class OnboardingCreateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => OnboardingCreateBloc(), child: const OnboardingCreatePage_());
  }
}

class OnboardingCreatePage_ extends StatefulWidget {
  const OnboardingCreatePage_({super.key});
  @override
  _OnboardingCreatePageState createState() => _OnboardingCreatePageState();
}

class _OnboardingCreatePageState extends State<OnboardingCreatePage_> {
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
        print('CREATE STATE: ${state.createState}');
        return Scaffold(
          appBar: AppBar(title: const Text('Horizon')),
          body: switch (state.createState) {
            CreateStateNotAsked => Mnemonic(),
            CreateStateMnemonicUnconfirmed => ConfirmSeedInputFields(
                mnemonicErrorState: state.mnemonicError,
              ),
            CreateStateMnemonicConfirmed => PasswordPrompt(
                passwordController: _passwordController,
                passwordConfirmationController: _passwordConfirmationController,
                state: state,
              ),
            // TODO: Handle this case.
            Object() => Text(''),
            // TODO: Handle this case.
            null => throw UnimplementedError(),
          },
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
                  onChanged: (value) {
                    context.read<OnboardingCreateBloc>().add(PasswordChanged(password: value));
                  },
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordConfirmationController,
                  onChanged: (value) {
                    context
                        .read<OnboardingCreateBloc>()
                        .add(PasswordConfirmationChanged(passwordConfirmation: _passwordConfirmationController.text));
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Confirm Password',
                  ),
                ),
                _state.passwordError != null ? Text(_state.passwordError!) : const Text(""),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.read<OnboardingCreateBloc>().add(CreateWallet()),
                          child: Text('Skip'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey, // Background color
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<OnboardingCreateBloc>().add(CreateWallet());
                          },
                          child: const Text('Create Wallet'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor, // Background color
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
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
  _MnemonicState createState() => _MnemonicState();
}

class _MnemonicState extends State<Mnemonic> {
  @override
  void initState() {
    super.initState();
    // Dispatching the GenerateMnemonic event to the Bloc
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
                CircularProgressIndicator()
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
                        onPressed: () => GoRouter.of(context).go('/onboarding'),
                        child: Text('Cancel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey, // Background color
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<OnboardingCreateBloc>().add(UnconfirmMnemonic());
                        },
                        child: const Text('Continue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor, // Background color
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
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
  ConfirmSeedInputFields({required String? this.mnemonicErrorState, super.key});
  @override
  State<ConfirmSeedInputFields> createState() => _ConfirmSeedInputFieldsState();
}

class _ConfirmSeedInputFieldsState extends State<ConfirmSeedInputFields> {
  List<TextEditingController> controllers = List.generate(12, (_) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(12, (_) => FocusNode());
  bool usePassphrase = false;

  @override
  void dispose() {
    controllers.forEach((controller) => controller.dispose());
    focusNodes.forEach((node) => node.dispose());
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
                                  Text("${index + 1}. ", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Expanded(
                                    child: TextField(
                                      controller: controllers[index],
                                      focusNode: focusNodes[index],
                                      onChanged: (value) => handleInput(value, index),
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
                  widget.mnemonicErrorState != null ? Text(widget.mnemonicErrorState!) : const Text(""),
                  ListTile(
                    leading: Checkbox(
                      value: usePassphrase,
                      onChanged: (bool? value) {
                        setState(() {
                          usePassphrase = value!;
                        });
                      },
                    ),
                    title: const Row(
                      children: [
                        Text('Passphrase'),
                        SizedBox(width: 4),
                        Tooltip(
                          message: "Password to encrypt your wallet in local storage",
                          child: Icon(Icons.help_outline, size: 20),
                        ),
                      ],
                    ),
                  ),
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
                    onPressed: () => GoRouter.of(context).go('/onboarding'),
                    child: Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, // Background color
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (usePassphrase) {
                        context.read<OnboardingCreateBloc>().add(ConfirmMnemonic());
                      } else {
                        context.read<OnboardingCreateBloc>().add(CreateWallet());
                      }
                      //   context.read<OnboardingImportBloc>().add(MnemonicSubmit(
                      //         mnemonic: controllers.map((controller) => controller.text).join(' ').trim(),
                      //         importFormat: selectedFormat!,
                      //       ));
                      // } else {
                      //   context.read<OnboardingImportBloc>().add(ImportWallet());
                      // }
                    },
                    child: const Text('Continue'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor, // Background color
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
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
    String mnemonic = controllers.map((controller) => controller.text).join(' ').trim();
    context.read<OnboardingCreateBloc>().add(ConfirmMnemonicChanged(mnemonic: mnemonic));
  }
}
