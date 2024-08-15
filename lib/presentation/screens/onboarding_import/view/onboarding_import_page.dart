import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_event.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_state.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';
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
    final backdropBackgroundColor =
        isDarkMode ? mediumNavyDarkTheme : lightBlueLightTheme;
    final scaffoldBackgroundColor =
        isDarkMode ? lightNavyDarkTheme : whiteLightTheme;

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
          backgroundColor: scaffoldBackgroundColor,
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
                  backgroundColor: scaffoldBackgroundColor,
                  appBar: AppBar(
                    backgroundColor: scaffoldBackgroundColor,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isDarkMode
                            ? SvgPicture.asset(
                                'assets/logo-white.svg',
                                width: 48,
                                height: 48,
                              )
                            : SvgPicture.asset(
                                'assets/logo-black.svg',
                                width: 48,
                                height: 48,
                              ),
                        const SizedBox(width: 8),
                        Text(
                          'Horizon',
                          style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode ? mainTextWhite : mainTextBlack),
                        ),
                      ],
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBackgroundColor =
        isDarkMode ? lightNavyDarkTheme : whiteLightTheme;
    final inputBackgroundColor =
        isDarkMode ? darkThemeInputColor : lightThemeInputColor;
    final cancelButtonBackgroundColor =
        isDarkMode ? noBackgroundColor : lightThemeInputColor;
    final continueButtonBackgroundColor =
        isDarkMode ? mediumNavyDarkTheme : royalBlueLightTheme;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                'Please create a password',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? mainTextWhite : mainTextBlack),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width / 3),
                child: const Text(
                  'This password will be used to encrypt and decrypt your seed phrase, which will be stored locally. You will be able to use your wallet with just your password, but you will only be able to recover your wallet with your seed phrase.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                constraints: const BoxConstraints(
                    minHeight: 48, minWidth: double.infinity),
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
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
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputBackgroundColor,
                        labelText: 'Password',
                        labelStyle: TextStyle(
                            color: isDarkMode
                                ? darkThemeInputLabelColor
                                : lightThemeInputLabelColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(
                    minHeight: 48, minWidth: double.infinity),
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
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
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputBackgroundColor,
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(
                            color: isDarkMode
                                ? darkThemeInputLabelColor
                                : lightThemeInputLabelColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _state.passwordError != null
                  ? Text(_state.passwordError!)
                  : const Text(""),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          overlayColor: noBackgroundColor,
                          elevation: 0,
                          backgroundColor: cancelButtonBackgroundColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16), // Button size
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ), // Text style
                        ),
                        onPressed: () {
                          final shell = context.read<ShellStateCubit>();
                          shell.onOnboarding();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('CANCEL',
                              style: TextStyle(
                                  color: isDarkMode
                                      ? mainTextGrey
                                      : mainTextBlack)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: continueButtonBackgroundColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16), // Button size
                          textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500), // Text style
                        ),
                        onPressed: () {
                          if (_passwordController.text == '' ||
                              _passwordConfirmationController.text == '') {
                            context.read<OnboardingImportBloc>().add(
                                PasswordError(
                                    error: 'Password cannot be empty'));
                          } else if (_passwordController.text !=
                              _passwordConfirmationController.text) {
                            context.read<OnboardingImportBloc>().add(
                                PasswordError(error: 'Passwords do not match'));
                          } else {
                            context
                                .read<OnboardingImportBloc>()
                                .add(ImportWallet());
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'LOGIN',
                            style: TextStyle(
                                color: isDarkMode
                                    ? neonBlueDarkTheme
                                    : mainTextWhite),
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
    final scaffoldBackgroundColor =
        isDarkMode ? lightNavyDarkTheme : whiteLightTheme;
    final cancelButtonBackgroundColor =
        isDarkMode ? noBackgroundColor : lightThemeInputColor;
    final continueButtonBackgroundColor =
        isDarkMode ? mediumNavyDarkTheme : royalBlueLightTheme;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: Column(
        children: [
          SizedBox(height: isSmallScreen ? 16 : 20),
          Expanded(
            child: isSmallScreen
                ? SingleChildScrollView(
                    child: buildInputFields(isSmallScreen, isDarkMode),
                  )
                : buildInputFields(isSmallScreen, isDarkMode),
          ),
          if (isSmallScreen) const SizedBox(height: 16),
          buildDropdownButton(isDarkMode),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    overlayColor: noBackgroundColor,
                    elevation: 0,
                    backgroundColor: cancelButtonBackgroundColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16), // Button size
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ), // Text style
                  ),
                  onPressed: () {
                    final shell = context.read<ShellStateCubit>();
                    shell.onOnboarding();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('CANCEL',
                        style: TextStyle(
                            color: isDarkMode ? mainTextGrey : mainTextBlack)),
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: continueButtonBackgroundColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    onPressed: () {
                      context.read<OnboardingImportBloc>().add(MnemonicSubmit(
                            mnemonic: controllers
                                .map((controller) => controller.text)
                                .join(' ')
                                .trim(),
                            importFormat: selectedFormat!,
                          ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'CONTINUE',
                        style: TextStyle(
                            color:
                                isDarkMode ? neonBlueDarkTheme : mainTextWhite),
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

  Widget buildInputFields(bool isSmallScreen, bool isDarkMode) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isSmallScreen) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      children: List.generate(12, (index) {
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                child: Text(
                                  "${index + 1}. ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? mainTextWhite
                                          : mainTextBlack),
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
                                    fillColor: isDarkMode
                                        ? darkThemeInputColor
                                        : lightThemeInputColor,
                                    labelText: 'Word ${index + 1}',
                                    labelStyle: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: isDarkMode
                                            ? darkThemeInputLabelColor
                                            : lightThemeInputLabelColor),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              widget.mnemonicErrorState != null
                  ? Text(widget.mnemonicErrorState!)
                  : const Text(""),
            ],
          );
        } else {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(2, (columnIndex) {
                        return Expanded(
                          child: Column(
                            children: List.generate(6, (rowIndex) {
                              int index = columnIndex * 6 + rowIndex;
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      child: Text(
                                        "${index + 1}. ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: isDarkMode
                                                ? mainTextWhite
                                                : mainTextBlack),
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
                                          fillColor: isDarkMode
                                              ? darkThemeInputColor
                                              : lightThemeInputColor,
                                          labelText: 'Word ${index + 1}',
                                          labelStyle: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: isDarkMode
                                                  ? darkThemeInputLabelColor
                                                  : lightThemeInputLabelColor),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        style: const TextStyle(fontSize: 16),
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
          );
        }
      },
    );
  }

  Widget buildDropdownButton(bool isDarkMode) {
    final dropdownBackgroundColor =
        isDarkMode ? darkThemeInputColor : lightThemeInputColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 12, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dropdownBackgroundColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: DropdownButtonHideUnderline(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
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
              dropdownColor: dropdownBackgroundColor,
              items: [
                _buildDropdownMenuItem(ImportFormat.segwit.name,
                    ImportFormat.segwit.description, dropdownBackgroundColor),
                _buildDropdownMenuItem(
                    ImportFormat.freewallet.name,
                    ImportFormat.freewallet.description,
                    dropdownBackgroundColor),
                _buildDropdownMenuItem(
                    ImportFormat.counterwallet.name,
                    ImportFormat.counterwallet.description,
                    dropdownBackgroundColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownMenuItem(
      String value, String description, Color backgroundColor) {
    return DropdownMenuItem<String>(
      value: value,
      child: MouseRegion(
        onEnter: (_) {},
        onExit: (_) {},
        onHover: (_) {},
        child: Text(description,
            style: const TextStyle(fontWeight: FontWeight.normal)),
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
                          value: ImportFormat.freewallet.name,
                          label: ImportFormat.freewallet.description,
                        ),
                        DropdownMenuEntry<String>(
                          value: ImportFormat.counterwallet.name,
                          label: ImportFormat.counterwallet.description,
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
