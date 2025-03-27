import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transactions/fee_confirmation.dart';
import 'package:horizon/presentation/common/transactions/transaction_fee_selection.dart';
import 'package:horizon/presentation/common/transactions/transaction_successful.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/domain/entities/compose_response.dart';

class StepContent {
  final String title;
  final List<Widget> widgets;

  const StepContent({
    required this.title,
    required this.widgets,
  });
}

// A transaction stepper widget that handles the UI for transaction flows.
// Includes three steps: inputs, confirmation, and submission.
class TransactionStepper<T, R> extends StatefulWidget {
  // Transaction form step
  final StepContent Function(
    MultiAddressBalance balances,
    FeeEstimates feeEstimates,
    FeeOption feeOption,
    T? data,
  ) buildFormStep;

  // Transaction confirmation step
  final StepContent Function(ComposeStateSuccess<R> composeState)
      buildConfirmationStep;

  // Callback for when dependencies are requested
  final VoidCallback onDependenciesRequested;

  // Callbacks for each step's "Next" button
  final VoidCallback onFormStepNext;
  final void Function({String? password}) onConfirmationStepNext;

  // Callback for when a fee option is selected
  final void Function(FeeOption) onFeeOptionSelected;

  // The transaction state
  final TransactionState<T, R> state;

  // Form key for the first step
  final GlobalKey<FormState> formKey;

  static const List<String> defaultButtonTexts = [
    'Review Transaction',
    'Sign and Submit',
  ];

  const TransactionStepper({
    super.key,
    required this.formKey,
    required this.buildFormStep,
    required this.buildConfirmationStep,
    required this.state,
    required this.onDependenciesRequested,
    required this.onFormStepNext,
    required this.onConfirmationStepNext,
    required this.onFeeOptionSelected,
  });

  @override
  State<TransactionStepper<T, R>> createState() =>
      _TransactionStepperState<T, R>();
}

class _TransactionStepperState<T, R> extends State<TransactionStepper<T, R>> {
  int _currentStep = 0;

  // Handle the next button press
  void _handleNext() async {
    switch (_currentStep) {
      case 0:
        // case 0: form step to confirmation step
        // Validate form before proceeding to next step
        if (!widget.formKey.currentState!.validate()) {
          return; // Stop if validation fails
        }
        widget.onFormStepNext();
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
                        widget.onConfirmationStepNext(password: password);
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
          widget.onConfirmationStepNext();
        }
        break;
      case 2:
        // case 2: submission step to close
        // no need to do anything
        break;
    }

    // Move to the next step if not on the last step
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  // Handle the back button press
  void _handleBack() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _currentStep--;
      });
    }
  }

  Widget _buildErrorWidget(BuildContext context, String errorMessage,
      {required VoidCallback onBack, required String buttonText}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppIcons.warningIcon(
          color: red1,
          width: 24,
          height: 24,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            errorMessage,
            style: const TextStyle(color: red1),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: HorizonOutlinedButton(
              onPressed: onBack,
              buttonText: buttonText,
              isTransparent: true,
            ),
          ),
        ),
      ],
    );
  }

  StepContent _buildSubmissionStep(BroadcastStateSuccess data) {
    return StepContent(
      title: 'Transaction Broadcasted',
      widgets: [
        TransactionSuccessful(
          transactionType: TransactionType.send,
          txHex: data.txHex,
          txHash: data.txHash,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 500;

    // Get the appropriate StepContent for the current step
    StepContent stepContent;

    if (_currentStep == 0) {
      if (widget.state.formInitial) {
        return _buildStepperContent(
          context,
          isSmallScreen,
          const StepContent(
            title: 'Enter Send Details',
            widgets: [
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ),
          showBackButton: false,
        );
      }

      if (widget.state.formLoading) {
        return _buildStepperContent(
          context,
          isSmallScreen,
          const StepContent(
            title: 'Enter Send Details',
            widgets: [
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ),
          showBackButton: false,
        );
      }

      if (widget.state.formLoadingError != null) {
        return _buildStepperContent(
          context,
          isSmallScreen,
          StepContent(
            title: 'Enter Send Details',
            widgets: [
              _buildErrorWidget(
                context,
                widget.state.formLoadingError!,
                onBack: () => widget.onDependenciesRequested(),
                buttonText: 'Reload',
              ),
            ],
          ),
          showBackButton: true,
        );
      }
      final balances = widget.state.getBalancesOrThrow();
      final feeEstimates = widget.state.getFeeEstimatesOrThrow();
      final feeOption = widget.state.feeOption;
      final data = widget.state.getDataOrThrow();

      final inputsStepContent =
          widget.buildFormStep(balances, feeEstimates, feeOption, data);

      // Add TransactionFeeSelection to the widgets if we're on the first step
      final updatedWidgets = [
        ...inputsStepContent.widgets,
        commonHeightSizedBox,
        TransactionFeeSelection(
          feeEstimates: feeEstimates,
          selectedFeeOption: feeOption,
          onFeeOptionSelected: widget.onFeeOptionSelected,
        )
      ];

      stepContent = StepContent(
        title: inputsStepContent.title,
        widgets: updatedWidgets,
      );
      return _buildStepperContent(context, isSmallScreen, stepContent,
          showBackButton: true);
    } else if (_currentStep == 1) {
      // Check for ComposeState errors or loading before building confirmation step
      return widget.state.composeState.when(
        initial: () => _buildStepperContent(
          context,
          isSmallScreen,
          const StepContent(
            title: 'Confirm Transaction',
            widgets: [
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ),
          showBackButton: false,
        ),
        loading: () => _buildStepperContent(
          context,
          isSmallScreen,
          const StepContent(
            title: 'Confirm Transaction',
            widgets: [
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ),
          showBackButton: false,
        ),
        error: (error) => _buildStepperContent(
          context,
          isSmallScreen,
          StepContent(
            title: 'Confirm Transaction',
            widgets: [
              _buildErrorWidget(
                context,
                error,
                onBack: () => setState(() => _currentStep--),
                buttonText: 'Go back to transaction',
              ),
            ],
          ),
          showBackButton: true,
        ),
        success: (composeData) {
          // Confirmation step
          final confirmationContent = widget
              .buildConfirmationStep(widget.state.getComposeStateOrThrow());
          final feeRate = getFeeRate(widget.state);

          final composeResponse =
              widget.state.getComposeDataOrThrow() as ComposeResponse;

          // Add FeeConfirmation to the widgets
          final updatedWidgets = [
            ...confirmationContent.widgets,
            commonHeightSizedBox,
            FeeConfirmation(
              fee: "${composeResponse.btcFee} sats ($feeRate sats/vbyte)",
              virtualSize: composeResponse.signedTxEstimatedSize.virtualSize,
              adjustedVirtualSize:
                  composeResponse.signedTxEstimatedSize.adjustedVirtualSize,
            ),
          ];

          stepContent = StepContent(
            title: confirmationContent.title,
            widgets: updatedWidgets,
          );

          return _buildStepperContent(context, isSmallScreen, stepContent,
              showBackButton: true);
        },
      );
    } else {
      // Submission step - handle broadcast state
      return widget.state.broadcastState.when(
        initial: () => _buildStepperContent(
          context,
          isSmallScreen,
          const StepContent(
            title: 'Transaction Submitted',
            widgets: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Your transaction is being processed'),
              ),
            ],
          ),
          showBackButton: false,
        ),
        loading: () => _buildStepperContent(
          context,
          isSmallScreen,
          const StepContent(
            title: 'Broadcasting Transaction',
            widgets: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: CircularProgressIndicator(),
              ),
            ],
          ),
          showBackButton: false,
        ),
        success: (data) => _buildStepperContent(
          context,
          isSmallScreen,
          _buildSubmissionStep(data),
          showBackButton: true,
        ),
        error: (error) => _buildStepperContent(
          context,
          isSmallScreen,
          StepContent(
            title: 'Broadcast Failed',
            widgets: [
              _buildErrorWidget(
                context,
                error,
                onBack: () => Navigator.of(context).pop(),
                buttonText: 'Close',
              ),
            ],
          ),
          showBackButton: true,
        ),
      );
    }
  }

  Widget _buildStepperContent(
      BuildContext context, bool isSmallScreen, StepContent stepContent,
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
                    onPressed: _handleBack,
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
                  stepContent.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _currentStep == 0
                      // wrap the first step in a form -- this will handle validating fields for us rather than passing the formKey into each input
                      ? Form(
                          key: widget.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: stepContent.widgets,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: stepContent.widgets,
                        ),
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
}
