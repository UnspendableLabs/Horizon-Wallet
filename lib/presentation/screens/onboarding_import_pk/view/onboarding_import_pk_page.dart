import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/presentation/screens/onboarding_import_pk/bloc/onboarding_import_pk_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_import_pk/bloc/onboarding_import_pk_event.dart';
import 'package:horizon/presentation/screens/onboarding_import_pk/bloc/onboarding_import_pk_state.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class OnboardingImportPKPage extends StatelessWidget {
  const OnboardingImportPKPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => OnboardingImportPKBloc(),
        child: const OnboardingImportPKPage_());
  }
}

class OnboardingImportPKPage_ extends StatefulWidget {
  const OnboardingImportPKPage_({super.key});
  @override
  _OnboardingImportPKPageState createState() => _OnboardingImportPKPageState();
}

class _OnboardingImportPKPageState extends State<OnboardingImportPKPage_> {
  final TextEditingController _passwordController =
      TextEditingController(text: "");
  final TextEditingController _passwordConfirmationController =
      TextEditingController(text: "");
  final TextEditingController _seedPhraseController =
      TextEditingController(text: "");
  final TextEditingController _importFormat =
      TextEditingController(text: ImportFormat.horizon.name);

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
          body: BlocListener<OnboardingImportPKBloc, OnboardingImportPKState>(
            listener: (context, state) async {
              if (state.importState is ImportStateSuccess) {
                final shell = context.read<ShellStateCubit>();
                // reload shell to trigger redirect
                shell.initialize();
              }
            },
            child: BlocBuilder<OnboardingImportPKBloc, OnboardingImportPKState>(
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
                            ? PKField(
                                pkErrorState: state.pkError,
                              )
                            : PasswordPrompt(
                                passwordController: _passwordController,
                                passwordConfirmationController:
                                    _passwordConfirmationController,
                                state: state,
                              ),
                      ),
                      // Flexible(
                      //   child: state.importState == ImportStateError
                      //       ? Text(state.importState!.message) : const SizedBox.shrink()
                      //
                      // ),
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
    required OnboardingImportPKState state,
  })  : _passwordController = passwordController,
        _passwordConfirmationController = passwordConfirmationController,
        _state = state;

  final TextEditingController _passwordController;
  final TextEditingController _passwordConfirmationController;
  final OnboardingImportPKState _state;

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
                            .read<OnboardingImportPKBloc>()
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
                        context.read<OnboardingImportPKBloc>().add(
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
              _state.importState is ImportStateError
                  ? Text(_state.importState.message)
                  : const SizedBox.shrink(),
              const SizedBox(width: 8),
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
                            context.read<OnboardingImportPKBloc>().add(
                                PasswordError(
                                    error: 'Password cannot be empty'));
                          } else if (_passwordController.text !=
                              _passwordConfirmationController.text) {
                            context.read<OnboardingImportPKBloc>().add(
                                PasswordError(error: 'Passwords do not match'));
                          } else {
                            print("importing wallet?");
                            context
                                .read<OnboardingImportPKBloc>()
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

class PKField extends StatefulWidget {
  final String? pkErrorState;
  const PKField({super.key, required this.pkErrorState});
  @override
  State<PKField> createState() => _PKFieldState();
}

class _PKFieldState extends State<PKField> {
  TextEditingController pkController = TextEditingController();

  String? selectedFormat = ImportFormat.horizon.name;

  @override
  void dispose() {
    pkController.dispose();
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
              child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: pkController,
                    onChanged: (value) {
                      context
                          .read<OnboardingImportPKBloc>()
                          .add(PKChanged(pk: value));
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDarkMode
                          ? darkThemeInputColor
                          : lightThemeInputColor,
                      labelText: 'Private Key',
                      helperText: 'Root BIP32 Extended Private Key',
                      labelStyle: TextStyle(
                        color: isDarkMode
                            ? darkThemeInputLabelColor
                            : lightThemeInputLabelColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (widget.pkErrorState != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        widget.pkErrorState!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          )),
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
                      context.read<OnboardingImportPKBloc>().add(PKSubmit(
                            pk: pkController.text,
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
                    .read<OnboardingImportPKBloc>()
                    .add(ImportFormatChanged(importFormat: newValue!));
              },
              dropdownColor: dropdownBackgroundColor,
              items: [
                _buildDropdownMenuItem(ImportFormat.horizon.name,
                    ImportFormat.horizon.description, dropdownBackgroundColor),
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
}
