import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';

class PasswordPrompt extends StatefulWidget {
  final Widget? optionalErrorWidget;
  final void Function(String)? onPasswordChanged;
  final VoidCallback? onValidationChanged;

  const PasswordPrompt({
    super.key,
    required this.state,
    this.optionalErrorWidget,
    this.onPasswordChanged,
    this.onValidationChanged,
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

  String get password => passwordController.text;
  bool get isValid {
    if (passwordController.text.isEmpty ||
        passwordConfirmationController.text.isEmpty) {
      return false;
    }
    return formKey.currentState?.validate() ?? false;
  }

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_onInputChanged);
    passwordConfirmationController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    if (widget.onPasswordChanged != null && isValid) {
      widget.onPasswordChanged!(password);
    }
    widget.onValidationChanged?.call();
  }

  @override
  void dispose() {
    passwordController.removeListener(_onInputChanged);
    passwordConfirmationController.removeListener(_onInputChanged);
    passwordController.dispose();
    passwordConfirmationController.dispose();
    super.dispose();
  }

  void clearPassword() {
    passwordController.clear();
    passwordConfirmationController.clear();
    setState(() {
      _submitted = false;
    });
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
                        color: isDarkMode ? Colors.white : Colors.black),
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
                          if (formKey.currentState!.validate()) {}
                        },
                        obscureText: _isPasswordObscured,
                        enableSuggestions: false,
                        autocorrect: false,
                        controller: passwordController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDarkMode
                              ? inputDarkBackground
                              : inputLightBackground,
                          labelText: 'Password',
                          labelStyle: TextStyle(
                              color: isDarkMode
                                  ? inputDarkLabelColor
                                  : inputLightLabelColor),
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
                              // Handle continue
                            }
                          },
                          obscureText: _isPasswordConfirmationObscured,
                          enableSuggestions: false,
                          autocorrect: false,
                          controller: passwordConfirmationController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDarkMode
                                ? inputDarkBackground
                                : inputLightBackground,
                            labelText: 'Confirm Password',
                            labelStyle: TextStyle(
                                color: isDarkMode
                                    ? inputDarkLabelColor
                                    : inputLightLabelColor),
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
