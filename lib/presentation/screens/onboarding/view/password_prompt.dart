import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/screens/onboarding/view/back_continue_buttons.dart';

class PasswordPrompt extends StatefulWidget {
  final Function() onPressedBack;
  final Function(String) onPressedContinue;
  final String backButtonText;
  final String continueButtonText;
  final Widget? optionalErrorWidget;

  const PasswordPrompt({
    super.key,
    required this.state,
    required this.onPressedBack,
    required this.onPressedContinue,
    required this.backButtonText,
    required this.continueButtonText,
    this.optionalErrorWidget,
  });

  final dynamic state;

  @override
  PasswordPromptState createState() => PasswordPromptState();
}

class PasswordPromptState extends State<PasswordPrompt> {
  final formKey = GlobalKey<FormState>();

  bool _isPasswordObscured = true;
  bool _isPasswordConfirmationObscured = true;
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    final isSmallScreen = screenSize.width < 768;

    return SingleChildScrollView(
      child: SizedBox(
        height: 500,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  !isSmallScreen
                      ? const SizedBox(height: 32)
                      : const SizedBox.shrink(),
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
                  Center(
                    child: SizedBox(
                      width: isSmallScreen
                          ? screenSize.width
                          : screenSize.width / 3,
                      child: TextFormField(
                        autovalidateMode: _submitted
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        validator: (value) => validatePassword(value),
                        onFieldSubmitted: (_) {
                          setState(() {
                            _submitted = true;
                          });
                          if (formKey.currentState!.validate()) {
                            widget.onPressedContinue(passwordController.text);
                          }
                        },
                        obscureText: _isPasswordObscured,
                        enableSuggestions: false,
                        autocorrect: false,
                        controller: passwordController,
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
                            focusNode: FocusNode(skipTraversal: true),
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
                        child: TextFormField(
                          autovalidateMode: _submitted
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          validator: (value) => validatePasswordConfirmation(
                              passwordController.text,
                              passwordConfirmationController.text),
                          onFieldSubmitted: (_) {
                            setState(() {
                              _submitted = true;
                            });
                            if (formKey.currentState!.validate()) {
                              widget.onPressedContinue(passwordController.text);
                            }
                          },
                          obscureText: _isPasswordConfirmationObscured,
                          enableSuggestions: false,
                          autocorrect: false,
                          controller: passwordConfirmationController,
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
                              focusNode: FocusNode(skipTraversal: true),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  widget.optionalErrorWidget != null
                      ? Column(
                          children: [
                            const SizedBox(height: 16),
                            widget.optionalErrorWidget!,
                          ],
                        )
                      : const SizedBox.shrink(),
                  const Spacer(),
                  BackContinueButtons(
                    isDarkMode: isDarkMode,
                    isSmallScreenWidth: isSmallScreen,
                    onPressedBack: widget.onPressedBack,
                    onPressedContinue: () {
                      setState(() {
                        _submitted = true;
                      });
                      if (formKey.currentState!.validate()) {
                        widget.onPressedContinue(passwordController.text);
                      }
                    },
                    backButtonText: widget.backButtonText,
                    continueButtonText: widget.continueButtonText,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String? validatePassword(String? password) {
  if (password == null || password.isEmpty) {
    return "Password cannot be empty";
  } else if (password.length < 8) {
    return "Password must be at least 8 characters";
  }
  return null;
}

String? validatePasswordConfirmation(String? password, String? confirmation) {
  if (password != null && password.isNotEmpty) {
    if (password.length < 8) {
      return "Password must be at least 8 characters";
    } else if (confirmation == null || confirmation.isEmpty) {
      return "Please confirm your password";
    } else if (password != confirmation) {
      return "Passwords do not match";
    }
  }
  return null;
}
