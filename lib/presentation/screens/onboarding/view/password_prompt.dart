import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/utils/app_icons.dart';

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
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

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

    // Add focus listeners
    passwordFocusNode.addListener(() {
      setState(() {});
    });
    confirmPasswordFocusNode.addListener(() {
      setState(() {});
    });
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

    // Remove focus listeners
    passwordFocusNode.removeListener(() {});
    confirmPasswordFocusNode.removeListener(() {});
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void clearPassword() {
    passwordController.clear();
    passwordConfirmationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 500;

    return Column(
      children: [
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: isSmallScreen ? 20.0 : 40.0),
          child: Column(
            children: [
              SelectableText(
                'Please create a password',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              SelectableText(
                'This password will be used to encrypt and decrypt your seed phrase, which will be stored locally. You will be able to use your wallet with just your password, but you will only be able to recover your wallet with your seed phrase.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: Form(
            key: formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20.0 : 40.0, vertical: 14.0),
              child: Column(
                children: [
                  buildPasswordField(
                    context,
                    controller: passwordController,
                    isObscured: _isPasswordObscured,
                    onToggleObscured: () {
                      setState(() {
                        _isPasswordObscured = !_isPasswordObscured;
                      });
                    },
                    label: 'Password',
                  ),
                  const SizedBox(height: 10),
                  buildPasswordField(
                    context,
                    controller: passwordConfirmationController,
                    isObscured: _isPasswordConfirmationObscured,
                    onToggleObscured: () {
                      setState(() {
                        _isPasswordConfirmationObscured =
                            !_isPasswordConfirmationObscured;
                      });
                    },
                    label: 'Confirm Password',
                  ),
                  if (widget.optionalErrorWidget != null) ...[
                    const SizedBox(height: 16),
                    widget.optionalErrorWidget!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPasswordField(
    BuildContext context, {
    required TextEditingController controller,
    required bool isObscured,
    required VoidCallback onToggleObscured,
    required String label,
  }) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    final hasText = controller.text.isNotEmpty;
    final focusNode =
        label == 'Password' ? passwordFocusNode : confirmPasswordFocusNode;

    return FormField<String>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) => label == 'Password'
          ? validatePassword(controller.text)
          : validatePasswordConfirmation(
              passwordController.text, controller.text),
      builder: (FormFieldState<String> field) {
        final hasError = field.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.text,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: hasText
                      ? customTheme.inputBackground
                      : customTheme.inputBackgroundEmpty,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: hasError
                        ? Border.all(color: customTheme.errorColor, width: 1)
                        : focusNode.hasFocus
                            ? const GradientBoxBorder(width: 1)
                            : Border.all(color: customTheme.inputBorderColor),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          obscureText: isObscured,
                          onChanged: (_) => field.didChange(controller.text),
                          onTap: () {
                            FocusScope.of(context).requestFocus(focusNode);
                          },
                          style: TextStyle(
                            fontSize: 12,
                            color: customTheme.inputTextColor,
                          ),
                          decoration: InputDecoration(
                            isDense: theme.inputDecorationTheme.isDense,
                            contentPadding:
                                theme.inputDecorationTheme.contentPadding,
                            border: theme.inputDecorationTheme.border,
                            hintText: label,
                            hintStyle: theme.inputDecorationTheme.hintStyle,
                          ),
                          showCursor: true,
                        ),
                      ),
                      AppIcons.iconButton(
                        context: context,
                        icon: isObscured
                            ? AppIcons.eyeOpenIcon(
                                context: context,
                                width: 18,
                                height: 18,
                              )
                            : AppIcons.eyeClosedIcon(
                                context: context,
                                width: 18,
                                height: 18,
                              ),
                        color: customTheme.inputTextColor,
                        onPressed: onToggleObscured,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (field.hasError) ...[
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  field.errorText!,
                  style: TextStyle(
                    color: customTheme.errorColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        );
      },
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
