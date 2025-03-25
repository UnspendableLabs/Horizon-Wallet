import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_bloc.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transactions/fee_confirmation.dart';
import 'package:horizon/presentation/common/transactions/transaction_fee_input.dart';
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

  // Transaction submission step
  final StepContent Function(BroadcastStateSuccess data) buildSubmissionStep;

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
    required this.buildSubmissionStep,
    required this.state,
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

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 500;

    if (widget.state.initial) {
      return _buildStepperContent(
        context,
        isSmallScreen,
        false,
        null,
        const StepContent(
          title: 'Enter Send Details',
          widgets: [
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
        null,
      );
    }

    if (widget.state.loadingFetch) {
      return _buildStepperContent(
        context,
        isSmallScreen,
        false,
        null,
        const StepContent(
          title: 'Enter Send Details',
          widgets: [
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
        null,
      );
    }

    if (widget.state.error != null) {
      return _buildStepperContent(
        context,
        isSmallScreen,
        false,
        null,
        StepContent(
          title: 'Enter Send Details',
          widgets: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.state.error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ),
          ],
        ),
        null,
      );
    }

    try {
      final balances = widget.state.getBalancesOrThrow();
      final feeEstimates = widget.state.getFeeEstimatesOrThrow();
      final data = widget.state.getDataOrThrow();

      return _buildMainContent(
        context,
        isSmallScreen,
        false, // No loading overlay
        null, // No error message
        balances: balances,
        feeEstimates: feeEstimates,
        feeOption: widget.state.feeOption,
        data: data,
      );
    } catch (e) {
      return _buildErrorContent(context, e.toString(), isSmallScreen);
    }
  }

  Widget _buildMainContent(
    BuildContext context,
    bool isSmallScreen,
    bool showLoadingOverlay,
    String? errorMessage, {
    MultiAddressBalance? balances,
    FeeEstimates? feeEstimates,
    FeeOption? feeOption,
    T? data,
  }) {
    // Get the appropriate StepContent for the current step
    StepContent stepContent;

    if (_currentStep == 0) {
      // For the first step, ensure we have all required data
      if (balances == null || feeEstimates == null || feeOption == null) {
        return _buildStepperContent(
          context,
          isSmallScreen,
          false,
          null,
          const StepContent(
            title: 'Enter Send Details',
            widgets: [
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ),
          null,
        );
      }

      // Inputs step - needs loading state
      final inputsStepContent =
          widget.buildFormStep(balances, feeEstimates, feeOption, data);

      // Add TransactionFeeInput to the widgets if we're on the first step
      final updatedWidgets = [
        ...inputsStepContent.widgets,
        commonHeightSizedBox,
        TransactionFeeInput(
          feeEstimates: feeEstimates,
          selectedFeeOption: feeOption,
          onFeeOptionSelected: widget.onFeeOptionSelected,
        )
      ];

      stepContent = StepContent(
        title: inputsStepContent.title,
        widgets: updatedWidgets,
      );
    } else if (_currentStep == 1) {
      // Check for ComposeState errors or loading before building confirmation step
      return widget.state.composeState.when(
        initial: () => _buildStepperContent(
          context,
          isSmallScreen,
          false,
          null,
          const StepContent(
            title: 'Confirm Transaction',
            widgets: [
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ),
          null,
        ),
        loading: () => _buildStepperContent(
          context,
          isSmallScreen,
          false,
          null,
          const StepContent(
            title: 'Confirm Transaction',
            widgets: [
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ),
          null,
        ),
        error: (error) => _buildStepperContent(
          context,
          isSmallScreen,
          false,
          null,
          StepContent(
            title: 'Confirm Transaction',
            widgets: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  error,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
            ],
          ),
          null,
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

          return _buildStepperContent(context, isSmallScreen,
              showLoadingOverlay, errorMessage, stepContent, null);
        },
      );
    } else {
      // Submission step - handle broadcast state
      return widget.state.broadcastState.when(
        initial: () => _buildStepperContent(
          context,
          isSmallScreen,
          showLoadingOverlay,
          errorMessage,
          const StepContent(
            title: 'Transaction Submitted',
            widgets: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Your transaction is being processed'),
              ),
            ],
          ),
          null,
        ),
        loading: () => _buildStepperContent(
          context,
          isSmallScreen,
          showLoadingOverlay,
          errorMessage,
          const StepContent(
            title: 'Broadcasting Transaction',
            widgets: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: CircularProgressIndicator(),
              ),
            ],
          ),
          null,
        ),
        success: (data) => _buildStepperContent(
          context,
          isSmallScreen,
          showLoadingOverlay,
          errorMessage,
          widget.buildSubmissionStep(data),
          null,
        ),
        error: (error) => _buildStepperContent(
          context,
          isSmallScreen,
          showLoadingOverlay,
          errorMessage,
          StepContent(
            title: 'Broadcast Failed',
            widgets: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Failed to broadcast transaction: $error',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
            ],
          ),
          null,
        ),
      );
    }

    return _buildStepperContent(context, isSmallScreen, showLoadingOverlay,
        errorMessage, stepContent, null);
  }

  Widget _buildStepperContent(
    BuildContext context,
    bool isSmallScreen,
    bool showLoadingOverlay,
    String? errorMessage,
    StepContent stepContent,
    Widget? errorWidget,
  ) {
    final stepperContent = Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: AppIcons.iconButton(
          context: context,
          width: 32,
          height: 32,
          icon: AppIcons.backArrowIcon(
              context: context, width: 24, height: 24, fit: BoxFit.fitHeight),
          onPressed: _handleBack,
        ),
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

              // Error display at top if there is an error
              if (errorWidget != null) errorWidget,

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _currentStep == 0
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
          if (showLoadingOverlay)
            Container(
              color: transparentWhite33,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
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

  // Helper method to build error content
  Widget _buildErrorContent(
      BuildContext context, String errorMessage, bool isSmallScreen) {
    final errorWidget = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'Error',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: HorizonOutlinedButton(
              onPressed: _handleBack,
              buttonText: 'Go Back',
              isTransparent: false,
            ),
          ),
        ],
      ),
    );

    final stepperContent = Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: AppIcons.iconButton(
            context: context,
            width: 32,
            height: 32,
            icon: AppIcons.backArrowIcon(
                context: context, width: 24, height: 24, fit: BoxFit.fitHeight),
            onPressed: _handleBack,
          )),
      body: Center(child: errorWidget),
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
