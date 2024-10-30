import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/logout/logout_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/logout/logout_event.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/screens/onboarding/view/back_continue_buttons.dart';

class LogoutDialog extends StatefulWidget {
  const LogoutDialog({super.key});

  @override
  State<LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  final resetConfirmationController = TextEditingController();
  bool hasConfirmedUnderstanding = false;
  String resetConfirmationText = '';
  String errorTextStepOne = '';
  String errorTextStepTwo = '';
  bool stepOne = true;
  @override
  void dispose() {
    resetConfirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    final state = context.watch<LogoutBloc>().state;

    return HorizonUI.HorizonDialog(
        onBackButtonPressed: () {
          GoRouter.of(context).pop();
        },
        title: 'Reset wallet',
        body: stepOne
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: redErrorText,
                        ),
                        children: [
                          TextSpan(text: 'All wallet data will be '),
                          TextSpan(
                            text: 'irreversibly deleted',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          TextSpan(text: '. You can recover your wallet '),
                          TextSpan(
                            text: 'only',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          TextSpan(
                              text:
                                  ' with your seed phrase. If you have multiple accounts, write down the total number—you\'ll need to recreate them manually after recovery. '),
                          TextSpan(
                            text:
                                '\n\nImported private keys won\'t reload  when you recover your wallet',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          TextSpan(
                              text: '—make sure you have them written down'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    fillColor: WidgetStateProperty.all(isDarkTheme
                        ? darkThemeInputColor
                        : lightBlueLightTheme),
                    value: hasConfirmedUnderstanding,
                    onChanged: (value) {
                      setState(() {
                        hasConfirmedUnderstanding = value ?? false;
                      });
                    },
                    title: const Text(
                      "I understand the consequences of this action and confirm I have written down my seed phrase, imported private keys, and account count.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  if (errorTextStepOne.isNotEmpty)
                    Column(
                      children: [
                        const SizedBox(height: 16),
                        SelectableText(
                          errorTextStepOne,
                          style: const TextStyle(color: redErrorText),
                        ),
                      ],
                    ),
                  BackContinueButtons(
                    isDarkMode: isDarkTheme,
                    isSmallScreenWidth: isSmallScreen,
                    onPressedBack: () {
                      GoRouter.of(context).pop();
                    },
                    backButtonText: 'CANCEL',
                    continueButtonText:
                        'CONTINUE', // The BackContinueButtons widget is the style/responiveness we want here, however we want the CANCEL button to be more prominent so that the user doesn't accidentally reset their wallet. In BackContinueButtons, the continue button is the one that is more prominent.
                    onPressedContinue: () {
                      if (!hasConfirmedUnderstanding) {
                        setState(() {
                          errorTextStepOne =
                              'You must confirm you have written down your seed phrase, imported private keys, and account count.';
                        });
                      } else {
                        setState(() {
                          stepOne = false;
                        });
                      }
                    },
                  ),
                ],
              )
            : Column(
                children: [
                  const SelectableText(
                    'Confirm reset wallet',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: redErrorText),
                  ),
                  const SizedBox(height: 16),
                  const SelectableText(
                    'This action is irreversible, and your wallet data will be permanently deleted.',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: redErrorText),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: resetConfirmationController,
                    decoration: const InputDecoration(
                      hintText: 'Enter text "RESET WALLET" to continue',
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (errorTextStepTwo.isNotEmpty)
                    Column(
                      children: [
                        const SizedBox(height: 16),
                        SelectableText(
                          errorTextStepTwo,
                          style: const TextStyle(color: redErrorText),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  BackContinueButtons(
                    isDarkMode: isDarkTheme,
                    isSmallScreenWidth: isSmallScreen,
                    onPressedBack: () {
                      GoRouter.of(context).pop();
                    },
                    backButtonText: 'CANCEL',
                    continueButtonText: 'RESET WALLET',
                    onPressedContinue: () {
                      if (resetConfirmationController.text == 'RESET WALLET') {
                        context.read<LogoutBloc>().add(LogoutEvent());
                      } else {
                        setState(() {
                          errorTextStepTwo =
                              'Please enter "RESET WALLET" to continue';
                        });
                      }
                    },
                  ),
                ],
              ));
  }
}
