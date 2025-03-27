import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/steps/transaction_broadcast.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/steps/transaction_form.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/utils/app_icons.dart';

class FormStepContent<T> {
  final String title;
  final TransactionFormStep<T> Function(TransactionFormState<T> formState)
      buildForm;
  final VoidCallback onNext;
  final Function(FeeOption) onFeeOptionSelected;
  final GlobalKey<FormState> formKey;

  const FormStepContent({
    required this.title,
    required this.buildForm,
    required this.onNext,
    required this.onFeeOptionSelected,
    required this.formKey,
  });
}

class ConfirmationStepContent<R> {
  final String title;
  final Widget Function(ComposeState<R> composeState) buildConfirmationContent;
  final void Function({String? password}) onNext;
  final VoidCallback backHandler;

  const ConfirmationStepContent({
    required this.title,
    required this.buildConfirmationContent,
    required this.onNext,
    required this.backHandler,
  });
}

// A transaction stepper widget that handles the UI for transaction flows.
// Includes three steps: inputs, confirmation, and submission.
class TransactionStepper<T, R> extends StatefulWidget {
  final FormStepContent<T> formStepContent;
  final ConfirmationStepContent<R> confirmationStepContent;
  final TransactionState<T, R> state;

  static const List<String> defaultButtonTexts = [
    'Review Transaction',
    'Sign and Submit',
  ];

  const TransactionStepper({
    super.key,
    required this.formStepContent,
    required this.confirmationStepContent,
    required this.state,
  });

  @override
  State<TransactionStepper<T, R>> createState() =>
      TransactionStepperState<T, R>();
}

class TransactionStepperState<T, R> extends State<TransactionStepper<T, R>> {
  int _currentStep = 0;

  void handleBack() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _currentStep--;
      });
    }
  }

  // Handle the next button press
  void _handleNext() async {
    switch (_currentStep) {
      case 0:
        // case 0: form step to confirmation step
        // Validate form before proceeding to next step
        if (!widget.formStepContent.formKey.currentState!.validate()) {
          return; // Stop if validation fails
        }
        widget.formStepContent.onNext();
        setState(() {
          _currentStep++;
        });
        break;
      case 1:
        // case 1: confirmation step to submission step
        final requirePassword =
            GetIt.I<SettingsRepository>().requirePasswordForCryptoOperations;

        if (requirePassword) {
          bool isAuthenticated = false;
          String? errorText;
          bool isLoading = false;

          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return HorizonPasswordPrompt(
                    onPasswordSubmitted: (password) async {
                      setState(() {
                        isLoading = true;
                        errorText = null;
                      });

                      try {
                        widget.confirmationStepContent
                            .onNext(password: password);
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop(true);
                        }
                      } catch (e) {
                        if (dialogContext.mounted) {
                          setState(() {
                            errorText = 'Invalid Password';
                            isLoading = false;
                          });
                        }
                      }
                    },
                    onCancel: () {
                      setState(() {
                        errorText = null;
                        isLoading = false;
                      });
                      Navigator.of(dialogContext).pop();
                    },
                    buttonText: 'Continue',
                    title: 'Enter Password',
                    errorText: errorText,
                    isLoading: isLoading,
                  );
                },
              );
            },
          ).then((value) {
            isAuthenticated = (value == true);
          });

          if (!isAuthenticated) {
            return;
          }
        } else {
          widget.confirmationStepContent.onNext();
        }
        setState(() {
          _currentStep++;
        });
        break;
      case 2:
        // case 2: submission step to close
        Navigator.of(context).pop();
        break;
    }
  }

  Widget _buildStepperContent(BuildContext context, bool isSmallScreen,
      Widget stepContent, String title,
      {required bool showBackButton}) {
    final stepperContent = Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // on the last step, show a close button rather than a back button
        leading: showBackButton
            ? _currentStep == 2
                ? AppIcons.iconButton(
                    context: context,
                    width: 32,
                    height: 32,
                    icon: AppIcons.closeIcon(
                      context: context,
                      width: 24,
                      height: 24,
                      fit: BoxFit.fitHeight,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : AppIcons.iconButton(
                    context: context,
                    width: 32,
                    height: 32,
                    icon: AppIcons.backArrowIcon(
                      context: context,
                      width: 24,
                      height: 24,
                      fit: BoxFit.fitHeight,
                    ),
                    onPressed: handleBack,
                  )
            : const SizedBox.shrink(),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Step indicators
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 30),
                child: Center(
                  child: Container(
                    width: 48,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: transparentWhite33,
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (_currentStep + 1) / 3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            colors: [
                              pinkGradient1,
                              purpleGradient1,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Step title
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 30),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: stepContent,
                ),
              ),
              // Bottom buttons
              _currentStep < 2
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 30, horizontal: isSmallScreen ? 20 : 40),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 64,
                              child: HorizonOutlinedButton(
                                isTransparent: false,
                                onPressed: _handleNext,
                                buttonText: TransactionStepper
                                    .defaultButtonTexts[_currentStep],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );

    if (isSmallScreen) {
      return stepperContent;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      body: Center(
        child: Container(
          width: 500,
          height: 812,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: stepperContent,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 500;

    if (_currentStep == 0) {
      return _buildStepperContent(
        context,
        isSmallScreen,
        widget.formStepContent.buildForm(widget.state.formState),
        widget.formStepContent.title,
        showBackButton: true,
      );
    } else if (_currentStep == 1) {
      return _buildStepperContent(
        context,
        isSmallScreen,
        widget.confirmationStepContent
            .buildConfirmationContent(widget.state.composeState),
        widget.confirmationStepContent.title,
        showBackButton: true,
      );
    } else {
      // Submission step - handle broadcast state
      return _buildStepperContent(
        context,
        isSmallScreen,
        TransactionBroadcast(
          broadcastState: widget.state.broadcastState,
        ),
        'Transaction Submitted',
        showBackButton: true,
      );
    }
  }
}
