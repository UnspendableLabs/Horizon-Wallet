import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/onboarding/view/back_continue_buttons.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';

class PasswordPrompt extends StatefulWidget {
  final Function(String) onPasswordChanged;
  final Function(String) onPasswordConfirmationChanged;
  final Function() onPressedBack;
  final Function() onPressedContinue;
  final String backButtonText;
  final String continueButtonText;
  final Widget? optionalErrorWiget;

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
    this.optionalErrorWiget,
  })  : _passwordController = passwordController,
        _passwordConfirmationController = passwordConfirmationController,
        _state = state;

  final TextEditingController _passwordController;
  final TextEditingController _passwordConfirmationController;
  final dynamic _state;

  @override
  _PasswordPromptState createState() => _PasswordPromptState();
}

class _PasswordPromptState extends State<PasswordPrompt> {
  bool _isPasswordObscured = true;
  bool _isPasswordConfirmationObscured = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBackgroundColor =
        isDarkMode ? lightNavyDarkTheme : whiteLightTheme;
    final isSmallScreen = MediaQuery.of(context).size.width < 768;
    final screenSize = MediaQuery.of(context).size;

    return Container(
      color: scaffoldBackgroundColor,
      child: Center(
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
                    maxWidth: isSmallScreen
                        ? screenSize.width
                        : screenSize.width / 2),
                child: const Text(
                  'This password will be used to encrypt and decrypt your seed phrase, which will be stored locally. You will be able to use your wallet with just your password, but you will only be able to recover your wallet with your seed phrase.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                constraints: BoxConstraints(
                    maxWidth: isSmallScreen
                        ? screenSize.width
                        : screenSize.width / 2),
                child: Center(
                  child: SizedBox(
                    width: isSmallScreen
                        ? screenSize.width
                        : screenSize.width / 3,
                    child: TextField(
                      obscureText: _isPasswordObscured,
                      enableSuggestions: false,
                      autocorrect: false,
                      controller: widget._passwordController,
                      onChanged: widget.onPasswordChanged,
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
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordObscured
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordObscured = !_isPasswordObscured;
                            });
                          },
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
                    width: isSmallScreen
                        ? screenSize.width
                        : screenSize.width / 3,
                    child: TextField(
                      obscureText: _isPasswordConfirmationObscured,
                      enableSuggestions: false,
                      autocorrect: false,
                      controller: widget._passwordConfirmationController,
                      onChanged: widget.onPasswordConfirmationChanged,
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
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordConfirmationObscured
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordConfirmationObscured =
                                  !_isPasswordConfirmationObscured;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              widget.optionalErrorWiget != null
                  ? widget.optionalErrorWiget!
                  : const SizedBox.shrink(),
              widget._state.passwordError != null
                  ? SelectableText(widget._state.passwordError!,
                      style: const TextStyle(
                        color: redErrorText,
                        fontSize: 16,
                      ))
                  : const Text(""),
              const Spacer(),
              BackContinueButtons(
                isDarkMode: isDarkMode,
                isSmallScreenWidth: isSmallScreen,
                onPressedBack: widget.onPressedBack,
                onPressedContinue: widget.onPressedContinue,
                backButtonText: widget.backButtonText,
                continueButtonText: widget.continueButtonText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
