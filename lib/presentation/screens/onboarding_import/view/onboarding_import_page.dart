import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/presentation/colors.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_event.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_state.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class OnboardingImportPage extends StatelessWidget {
  const OnboardingImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => OnboardingImportBloc(),
        child: const OnboardingImportPage_());
  }
}

class OnboardingImportPage_ extends StatefulWidget {
  const OnboardingImportPage_({super.key});
  @override
  _OnboardingImportPageState createState() => _OnboardingImportPageState();
}

class _OnboardingImportPageState extends State<OnboardingImportPage_> {
  final TextEditingController _passwordController =
      TextEditingController(text: "");
  final TextEditingController _passwordConfirmationController =
      TextEditingController(text: "");
  final TextEditingController _seedPhraseController =
      TextEditingController(text: "");
  final TextEditingController _importFormat =
      TextEditingController(text: ImportFormat.segwit.name);

  @override
  dispose() {
    _seedPhraseController.dispose();
    _importFormat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 768;
    final EdgeInsetsGeometry padding = isSmallScreen
        ? const EdgeInsets.all(8.0)
        : EdgeInsets.symmetric(
            horizontal: screenSize.width / 8,
            vertical: screenSize.height / 16,
          );
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backdropBackgroundColor = isDarkMode
        ? mediumNavyDarkThemeBackgroundColor
        : lightBlueLightThemeBackgroundColor;
    final scaffoldBackgroundColor = isDarkMode
        ? lightNavyDarkThemeBackgroundColor
        : whiteLightThemeBackgroundColor;

    return Container(
      decoration: BoxDecoration(
        color: backdropBackgroundColor,
      ),
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          color: scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.all(12),
        child: Scaffold(
          backgroundColor:
              Colors.transparent, // Make Scaffold background transparent
          body: BlocListener<OnboardingImportBloc, OnboardingImportState>(
            listener: (context, state) async {
              if (state.importState is ImportStateSuccess) {
                final shell = context.read<ShellStateCubit>();
                // reload shell to trigger redirect
                shell.initialize();
              }
            },
            child: BlocBuilder<OnboardingImportBloc, OnboardingImportState>(
                builder: (context, state) {
              return Container(
                decoration: BoxDecoration(
                  color: scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Scaffold(
                  backgroundColor: Colors
                      .transparent, // Make inner Scaffold background transparent
                  appBar: AppBar(
                    backgroundColor: scaffoldBackgroundColor,
                    title: const Text(
                      'Horizon',
                      style:
                          TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                    ),
                  ),
                  body: Column(
                    children: [
                      Flexible(
                        child: state.importState == ImportStateNotAsked
                            ? SeedInputFields(
                                mnemonicErrorState: state.mnemonicError,
                              )
                            : PasswordPrompt(
                                passwordController: _passwordController,
                                passwordConfirmationController:
                                    _passwordConfirmationController,
                                state: state,
                              ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class PasswordPrompt extends StatelessWidget {
  const PasswordPrompt({
    super.key,
    required TextEditingController passwordController,
    required TextEditingController passwordConfirmationController,
    required OnboardingImportState state,
  })  : _passwordController = passwordController,
        _passwordConfirmationController = passwordConfirmationController,
        _state = state;

  final TextEditingController _passwordController;
  final TextEditingController _passwordConfirmationController;
  final OnboardingImportState _state;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Text('Password', style: TextStyle(fontSize: 16)),
            SizedBox(width: 4),
            Tooltip(
              message:
                  'This password will be used to locally encrypt your wallet.',
              child: Icon(Icons.info, size: 12),
            ),
          ]),
          Expanded(
            child: Column(
              children: [
                Container(
                    constraints: const BoxConstraints(
                        minHeight: 48,
                        minWidth: double
                            .infinity), // Minimum height for the TextField
                    child: TextField(
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      controller: _passwordController,
                      onChanged: (value) {
                        context
                            .read<OnboardingImportBloc>()
                            .add(PasswordChanged(password: value));
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                    )),
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(
                      minHeight: 48,
                      minWidth:
                          double.infinity), // Minimum height for the TextField
                  child: TextField(
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    controller: _passwordConfirmationController,
                    onChanged: (value) {
                      context.read<OnboardingImportBloc>().add(
                          PasswordConfirmationChanged(
                              passwordConfirmation: value));
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Confirm Password',
                    ),
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
                        child: FilledButton(
                          onPressed: () {
                            final shell = context.read<ShellStateCubit>();

                            shell.onOnboarding();
                          },
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            if (_passwordController.text == '' ||
                                _passwordConfirmationController.text == '') {
                              context.read<OnboardingImportBloc>().add(
                                  PasswordError(
                                      error: 'Password cannot be empty'));
                            } else if (_passwordController.text !=
                                _passwordConfirmationController.text) {
                              context.read<OnboardingImportBloc>().add(
                                  PasswordError(
                                      error: 'Passwords do not match'));
                            } else {
                              context
                                  .read<OnboardingImportBloc>()
                                  .add(ImportWallet());
                            }
                          },
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text('Import Wallet'),
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

class SeedInputFields extends StatefulWidget {
  final String? mnemonicErrorState;
  const SeedInputFields({super.key, required this.mnemonicErrorState});
  @override
  State<SeedInputFields> createState() => _SeedInputFieldsState();
}

class _SeedInputFieldsState extends State<SeedInputFields> {
  List<TextEditingController> controllers =
      List.generate(12, (_) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(12, (_) => FocusNode());
  String? selectedFormat = ImportFormat.segwit.name;

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
    final isSmallScreen = MediaQuery.of(context).size.width < 768;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBackgroundColor = isDarkMode
        ? lightNavyDarkThemeBackgroundColor
        : whiteLightThemeBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: Column(
        children: [
          SizedBox(height: isSmallScreen ? 16 : 20),
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                height: isSmallScreen
                    ? null
                    : 600, // Greater height for larger screens
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: isSmallScreen
                          ? [
                              Expanded(
                                child: Column(
                                  children: List.generate(12, (index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(
                                          12.0), // More whitespace between individual inputs
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width:
                                                24, // Fixed width for alignment
                                            child: Text(
                                              "${index + 1}. ",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign
                                                  .right, // Align text to the right
                                            ),
                                          ),
                                          const SizedBox(
                                              width:
                                                  4), // Space between number and input
                                          Expanded(
                                            child: TextField(
                                              controller: controllers[index],
                                              focusNode: focusNodes[index],
                                              onChanged: (value) =>
                                                  handleInput(value, index),
                                              onEditingComplete: () =>
                                                  handleTabNavigation(index),
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.grey[300],
                                                labelText: 'Word ${index + 1}',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0), // Rounded borders
                                                  borderSide: BorderSide.none,
                                                ),
                                              ),
                                              style: const TextStyle(
                                                  fontSize:
                                                      16), // Slightly taller inputs
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ]
                          : List.generate(2, (columnIndex) {
                              return Expanded(
                                child: Column(
                                  children: List.generate(6, (rowIndex) {
                                    int index = columnIndex * 6 + rowIndex;
                                    return Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 24,
                                            child: Text(
                                              "${index + 1}. ",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: TextField(
                                              controller: controllers[index],
                                              focusNode: focusNodes[index],
                                              onChanged: (value) =>
                                                  handleInput(value, index),
                                              onEditingComplete: () =>
                                                  handleTabNavigation(index),
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.grey[300],
                                                labelText: 'Word ${index + 1}',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: BorderSide.none,
                                                ),
                                              ),
                                              style:
                                                  const TextStyle(fontSize: 16),
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
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DropdownButtonHideUnderline(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedFormat,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFormat = newValue;
                    });
                    context
                        .read<OnboardingImportBloc>()
                        .add(ImportFormatChanged(importFormat: newValue!));
                  },
                  items: [
                    DropdownMenuItem<String>(
                      value: ImportFormat.segwit.name,
                      child: Text(ImportFormat.segwit.description),
                    ),
                    DropdownMenuItem<String>(
                      value: ImportFormat.freewalletBech32.name,
                      child: Text(ImportFormat.freewalletBech32.description),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilledButton(
                  onPressed: () {
                    final shell = context.read<ShellStateCubit>();
                    shell.onOnboarding();
                  },
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontSize: 14)),
                ),
                FilledButton(
                  onPressed: () {
                    context.read<OnboardingImportBloc>().add(MnemonicSubmit(
                          mnemonic: controllers
                              .map((controller) => controller.text)
                              .join(' ')
                              .trim(),
                          importFormat: selectedFormat!,
                        ));
                  },
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 14)),
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

  void handleTabNavigation(int index) {
    int nextIndex = index + 1;
    if (nextIndex < 12) {
      FocusScope.of(context).requestFocus(focusNodes[nextIndex]);
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  void updateMnemonic() {
    String mnemonic =
        controllers.map((controller) => controller.text).join(' ').trim();
    context
        .read<OnboardingImportBloc>()
        .add(MnemonicChanged(mnemonic: mnemonic));
  }
}

class SeedPrompt extends StatelessWidget {
  const SeedPrompt({
    super.key,
    required TextEditingController seedPhraseController,
    required OnboardingImportState state,
  })  : _seedPhraseController = seedPhraseController,
        _state = state;

  final TextEditingController _seedPhraseController;
  final OnboardingImportState _state;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
          margin: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Column(children: [
                TextField(
                  controller: _seedPhraseController,
                  onChanged: (value) {
                    context
                        .read<OnboardingImportBloc>()
                        .add(MnemonicChanged(mnemonic: value));
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Seed phrase',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    DropdownMenu<String>(
                      label: const Text("Import format"),
                      onSelected: (newValue) {
                        context
                            .read<OnboardingImportBloc>()
                            .add(ImportFormatChanged(importFormat: newValue!));
                      },
                      initialSelection: ImportFormat.segwit.name,
                      dropdownMenuEntries: [
                        DropdownMenuEntry<String>(
                          value: ImportFormat.segwit.name,
                          label: ImportFormat.segwit.description,
                        ),
                        // DropdownMenuEntry<String>(
                        //   value: ImportFormat.legacy.name,
                        //   label: ImportFormat.legacy.description,
                        // ),
                        DropdownMenuEntry<String>(
                          value: ImportFormat.freewalletBech32.name,
                          label: ImportFormat.freewalletBech32.description,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ])),
              _state.importState is ImportStateError
                  ? Text(_state.importState.message)
                  : const Text(""),
              Row(children: [
                // TODO: figure out how to disable a button
                ElevatedButton(
                  onPressed: () {
                    context.read<OnboardingImportBloc>().add(ImportWallet());
                  },
                  child: const Text('Import Addresses'),
                ),
              ]),
              _state.importState is ImportStateLoading
                  ? const CircularProgressIndicator()
                  : const Text("")
            ],
          )),
    );
  }
}

class AddressListView extends StatelessWidget {
  final List<Address> addresses;
  final Map<Address, bool> isCheckedMap;
  final void Function(Address, bool) onCheckedChanged;

  const AddressListView({
    super.key,
    required this.addresses,
    required this.isCheckedMap,
    required this.onCheckedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: ListView.builder(
          shrinkWrap: true,
          // physics: const NeverScrollableScrollPhysics(),
          itemCount: addresses.length,
          itemBuilder: (context, index) {
            final address = addresses[index];
            return AddressListItem(
              address: address,
              isChecked: isCheckedMap[address] ?? false,
              onCheckedChanged: (isChecked) {
                onCheckedChanged(address, isChecked);
              },
            );
          },
        ),
      ),
    );
  }
}

class AddressListItem extends StatelessWidget {
  final Address address;
  final bool isChecked;
  final ValueChanged<bool> onCheckedChanged;

  const AddressListItem({
    super.key,
    required this.address,
    required this.isChecked,
    required this.onCheckedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: isChecked,
        onChanged: (value) {
          onCheckedChanged(value!);
        },
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              address.address,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      // subtitle: Text(address.derivationPath),
    );
  }
}
