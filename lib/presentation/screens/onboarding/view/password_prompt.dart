import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/onboarding/view/back_continue_buttons.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';

class PasswordPrompt extends StatelessWidget {
  final Function(String) onPasswordChanged;
  final Function(String) onPasswordConfirmationChanged;
  final Function() onPressedBack;
  final Function() onPressedContinue;
  final String backButtonText;
  final String continueButtonText;

  const PasswordPrompt({
    super.key,
    required TextEditingController passwordController,
    required TextEditingController passwordConfirmationController,
    required dynamic state,
    required this.onPasswordChanged,
    required this.onPasswordConfirmationChanged,
    required this.onPressedBack,
    required this.onPressedContinue,
    required this.backButtonText,
    required this.continueButtonText,
  })  : _passwordController = passwordController,
        _passwordConfirmationController = passwordConfirmationController,
        _state = state;

  final TextEditingController _passwordController;
  final TextEditingController _passwordConfirmationController;
  final dynamic _state;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBackgroundColor =
        isDarkMode ? lightNavyDarkTheme : whiteLightTheme;
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
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? mainTextWhite : mainTextBlack),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width / 2),
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
                      onChanged: onPasswordChanged,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDarkMode
                            ? darkThemeInputColor
                            : lightThemeInputColor,
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
                      onChanged: onPasswordConfirmationChanged,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDarkMode
                            ? darkThemeInputColor
                            : lightThemeInputColor,
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
                  ? Text(_state.passwordError!,
                      style: TextStyle(
                          color: redErrorText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold))
                  : const Text(""),
              const Spacer(),
              BackContinueButtons(
                isDarkMode: isDarkMode,
                isSmallScreenWidth: isSmallScreen,
                onPressedBack: onPressedBack,
                onPressedContinue: onPressedContinue,
                backButtonText: backButtonText,
                continueButtonText: continueButtonText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
