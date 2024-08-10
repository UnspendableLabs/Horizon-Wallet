import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_event.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_state.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class OnboardingCreateScreen extends StatelessWidget {
  const OnboardingCreateScreen({super.key});

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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 768;
    final EdgeInsetsGeometry padding = isSmallScreen
        ? const EdgeInsets.all(8.0)
        : EdgeInsets.symmetric(
            horizontal: screenSize.width / 8,
            vertical: screenSize.height / 16,
          );
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backdropBackgroundColor = isDarkMode ? mediumNavyDarkTheme : lightBlueLightTheme;
    final scaffoldBackgroundColor = isDarkMode ? lightNavyDarkTheme : whiteLightTheme;

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
          body: BlocListener<OnboardingCreateBloc, OnboardingCreateState>(
            listener: (context, state) {
              if (state.createState is CreateStateSuccess) {
                final shell = context.read<ShellStateCubit>();
                // reload shell to trigger redirect
                shell.initialize();
              }
            },
            child: BlocBuilder<OnboardingCreateBloc, OnboardingCreateState>(builder: (context, state) {
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
                              fontSize: 34, fontWeight: FontWeight.bold, color: isDarkMode ? mainTextWhite : mainTextBlack),
                        ),
                      ],
                    ),
                  ),
                  body: Column(
                    children: [
                      Flexible(
                        child: BlocBuilder<OnboardingCreateBloc, OnboardingCreateState>(builder: (context, state) {
                          return Scaffold(
                            body: switch (state.createState) {
                              CreateStateNotAsked => const Mnemonic(),
                              CreateStateMnemonicUnconfirmed => ConfirmSeedInputFields(
                                  mnemonicErrorState: state.mnemonicError,
                                ),
                              CreateStateMnemonicConfirmed => PasswordPrompt(
                                  passwordController: _passwordController,
                                  passwordConfirmationController: _passwordConfirmationController,
                                  state: state,
                                ),
                              Object() => const Text(''),
                              null => throw UnimplementedError(),
                            },
                          );
                        }),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBackgroundColor = isDarkMode ? lightNavyDarkTheme : whiteLightTheme;
    final cancelButtonBackgroundColor = isDarkMode ? noBackgroundColor : lightThemeInputColor;
    final continueButtonBackgroundColor = isDarkMode ? mediumNavyDarkTheme : royalBlueLightTheme;
    final isSmallScreen = MediaQuery.of(context).size.width < 768;

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
                style:
                    TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? mainTextWhite : mainTextBlack),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 3),
                child: const Text(
                  'This password will be used to encrypt and decrypt your seed phrase, which will be stored locally. You will be able to use your wallet with just your password, but you will only be able to recover your wallet with your seed phrase.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                constraints: const BoxConstraints(minHeight: 48, minWidth: double.infinity),
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: TextField(
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      controller: _passwordController,
                      onChanged: (value) {
                        context.read<OnboardingCreateBloc>().add(PasswordChanged(password: value));
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDarkMode ? darkThemeInputColor : lightThemeInputColor,
                        labelText: 'Password',
                        labelStyle: TextStyle(color: isDarkMode ? darkThemeInputLabelColor : lightThemeInputLabelColor),
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
                constraints: const BoxConstraints(minHeight: 48, minWidth: double.infinity),
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: TextField(
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      controller: _passwordConfirmationController,
                      onChanged: (value) {
                        context.read<OnboardingCreateBloc>().add(PasswordConfirmationChanged(passwordConfirmation: value));
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDarkMode ? darkThemeInputColor : lightThemeInputColor,
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(color: isDarkMode ? darkThemeInputLabelColor : lightThemeInputLabelColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _state.passwordError != null ? Text(_state.passwordError!) : const Text(""),
              const Spacer(),
              if (isSmallScreen) const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: SizedBox(
                        width: isSmallScreen ? double.infinity : 150,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            overlayColor: noBackgroundColor,
                            elevation: 0,
                            backgroundColor: cancelButtonBackgroundColor,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Button size
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
                                style: TextStyle(color: isDarkMode ? greyDarkTheme : mainTextBlack)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: SizedBox(
                        width: isSmallScreen ? double.infinity : 250,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: continueButtonBackgroundColor,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          onPressed: () {
                            if (_passwordController.text == '' || _passwordConfirmationController.text == '') {
                              context.read<OnboardingCreateBloc>().add(PasswordError(error: 'Password cannot be empty'));
                            } else if (_passwordController.text != _passwordConfirmationController.text) {
                              context.read<OnboardingCreateBloc>().add(PasswordError(error: 'Passwords do not match'));
                            } else {
                              context.read<OnboardingCreateBloc>().add(CreateWallet());
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'CONTINUE',
                              style: TextStyle(color: isDarkMode ? neonBlueDarkTheme : mainTextWhite),
                            ),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBackgroundColor = isDarkMode ? lightNavyDarkTheme : whiteLightTheme;
    final cancelButtonBackgroundColor = isDarkMode ? noBackgroundColor : lightThemeInputColor;
    final continueButtonBackgroundColor = isDarkMode ? mediumNavyDarkTheme : royalBlueLightTheme;
    final isSmallScreen = MediaQuery.of(context).size.width < 768;

    return BlocBuilder<OnboardingCreateBloc, OnboardingCreateState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: scaffoldBackgroundColor,
          body: Center(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.mnemonicState is GenerateMnemonicStateLoading)
                    const CircularProgressIndicator()
                  else if (state.mnemonicState is GenerateMnemonicStateGenerated)
                    Expanded(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.topLeft,
                              child: SvgPicture.asset(
                                color: onboardingQuoteDarkThemeColor,
                                'assets/open-quote.svg',
                                width: 48,
                                height: 48,
                              ),
                            ),
                            SelectableText(
                              textAlign: TextAlign.center,
                              state.mnemonicState.mnemonic,
                              style: TextStyle(
                                color: isDarkMode ? mainTextWhite : mainTextBlack,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 35 : 45,
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: SvgPicture.asset(
                                color: onboardingQuoteDarkThemeColor,
                                'assets/closed-quote.svg',
                                width: 48,
                                height: 48,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              textAlign: TextAlign.center,
                              'Please write down your seed phrase in a secure location. It is the only way to recover your wallet.',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: SizedBox(
                            width: isSmallScreen ? double.infinity : 150,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                overlayColor: noBackgroundColor,
                                elevation: 0,
                                backgroundColor: cancelButtonBackgroundColor,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Button size
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
                                    style: TextStyle(color: isDarkMode ? greyDarkTheme : mainTextBlack)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: SizedBox(
                            width: isSmallScreen ? double.infinity : 250,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: continueButtonBackgroundColor,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              onPressed: () {
                                context.read<OnboardingCreateBloc>().add(UnconfirmMnemonic());
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'CONTINUE',
                                  style: TextStyle(color: isDarkMode ? neonBlueDarkTheme : mainTextWhite),
                                ),
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
  List<TextEditingController> controllers = List.generate(12, (_) => TextEditingController());
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
    final isSmallScreen = MediaQuery.of(context).size.width < 768;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBackgroundColor = isDarkMode ? lightNavyDarkTheme : whiteLightTheme;
    final cancelButtonBackgroundColor = isDarkMode ? noBackgroundColor : lightThemeInputColor;
    final continueButtonBackgroundColor = isDarkMode ? mediumNavyDarkTheme : royalBlueLightTheme;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: Column(
        children: [
          SizedBox(height: isSmallScreen ? 16 : 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Text(
              textAlign: TextAlign.center,
              'Please confirm your seed phrase',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: isDarkMode ? mainTextWhite : mainTextBlack),
            ),
          ),
          Expanded(
            child: isSmallScreen
                ? SingleChildScrollView(
                    child: buildInputFields(isSmallScreen, isDarkMode),
                  )
                : buildInputFields(isSmallScreen, isDarkMode),
          ),
          if (isSmallScreen) const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    overlayColor: noBackgroundColor,
                    elevation: 0,
                    backgroundColor: cancelButtonBackgroundColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Button size
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ), // Text style
                  ),
                  onPressed: () {
                    context.read<OnboardingCreateBloc>().add(GoBackToMnemonic());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('BACK', style: TextStyle(color: isDarkMode ? greyDarkTheme : mainTextBlack)),
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: continueButtonBackgroundColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    onPressed: () {
                      context.read<OnboardingCreateBloc>().add(ConfirmMnemonic(
                            mnemonic: controllers.map((controller) => controller.text).join(' ').trim(),
                          ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'CONTINUE',
                        style: TextStyle(color: isDarkMode ? neonBlueDarkTheme : mainTextWhite),
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
                                      fontWeight: FontWeight.bold, color: isDarkMode ? mainTextWhite : mainTextBlack),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: TextField(
                                  controller: controllers[index],
                                  focusNode: focusNodes[index],
                                  onChanged: (value) => handleInput(value, index),
                                  onEditingComplete: () => handleTabNavigation(index),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: isDarkMode ? darkThemeInputColor : lightThemeInputColor,
                                    labelText: 'Word ${index + 1}',
                                    labelStyle: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: isDarkMode ? darkThemeInputLabelColor : lightThemeInputLabelColor),
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
              widget.mnemonicErrorState != null ? Text(widget.mnemonicErrorState!) : const Text(""),
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
                                            color: isDarkMode ? mainTextWhite : mainTextBlack),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: TextField(
                                        controller: controllers[index],
                                        focusNode: focusNodes[index],
                                        onChanged: (value) => handleInput(value, index),
                                        onEditingComplete: () => handleTabNavigation(index),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: isDarkMode ? darkThemeInputColor : lightThemeInputColor,
                                          labelText: 'Word ${index + 1}',
                                          labelStyle: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: isDarkMode ? darkThemeInputLabelColor : lightThemeInputLabelColor),
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
                        );
                      }),
                    ),
                    widget.mnemonicErrorState != null ? Text(widget.mnemonicErrorState!) : const Text(""),
                  ],
                ),
              ),
            ),
          );
        }
      },
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
    String mnemonic = controllers.map((controller) => controller.text).join(' ').trim();
    context.read<OnboardingCreateBloc>().add(ConfirmMnemonicChanged(mnemonic: mnemonic));
  }
}
