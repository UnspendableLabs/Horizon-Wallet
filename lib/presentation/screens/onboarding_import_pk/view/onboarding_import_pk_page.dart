import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/presentation/screens/onboarding/view/back_continue_buttons.dart';
import 'package:horizon/presentation/screens/onboarding/view/onboarding_app_bar.dart';
import 'package:horizon/presentation/screens/onboarding/view/password_prompt.dart';
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
                  appBar: OnboardingAppBar(
                    isDarkMode: isDarkMode,
                    isSmallScreenWidth: isSmallScreen,
                    isSmallScreenHeight: isSmallScreen,
                    scaffoldBackgroundColor: scaffoldBackgroundColor,
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
                                onPasswordChanged: (value) {
                                  context.read<OnboardingImportPKBloc>().add(
                                      PasswordChanged(
                                          password: value,
                                          passwordConfirmation:
                                              _passwordConfirmationController
                                                  .text));
                                },
                                onPasswordConfirmationChanged: (value) {
                                  context.read<OnboardingImportPKBloc>().add(
                                      PasswordConfirmationChanged(
                                          passwordConfirmation: value));
                                },
                                onPressedBack: () {
                                  final shell = context.read<ShellStateCubit>();
                                  shell.onOnboarding();
                                },
                                onPressedContinue: () {
                                  if (_passwordController.text == '' ||
                                      _passwordConfirmationController.text ==
                                          '') {
                                    context.read<OnboardingImportPKBloc>().add(
                                        PasswordError(
                                            error: 'Password cannot be empty'));
                                  } else if (_passwordController.text !=
                                      _passwordConfirmationController.text) {
                                    context.read<OnboardingImportPKBloc>().add(
                                        PasswordError(
                                            error: 'Passwords do not match'));
                                  } else {
                                    context
                                        .read<OnboardingImportPKBloc>()
                                        .add(ImportWallet());
                                  }
                                },
                                backButtonText: 'CANCEL',
                                continueButtonText: 'LOGIN',
                                optionalErrorWiget: state.importState
                                        is ImportStateError
                                    ? Positioned(
                                        top: 0, // Adjust the position as needed
                                        left:
                                            0, // Adjust the position as needed
                                        right:
                                            0, // Adjust the position as needed
                                        child: Align(
                                          child: Center(
                                            child: Text(
                                              state.importState.message,
                                              style: const TextStyle(
                                                  color: redErrorText),
                                            ),
                                          ),
                                        ),
                                      )
                                    : null,
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
          BackContinueButtons(
              isDarkMode: isDarkMode,
              isSmallScreenWidth: isSmallScreen,
              onPressedBack: () {
                final shell = context.read<ShellStateCubit>();
                shell.onOnboarding();
              },
              onPressedContinue: () {
                context.read<OnboardingImportPKBloc>().add(PKSubmit(
                      pk: pkController.text,
                      importFormat: selectedFormat!,
                    ));
              },
              backButtonText: 'CANCEL',
              continueButtonText: 'CONTINUE'),
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
