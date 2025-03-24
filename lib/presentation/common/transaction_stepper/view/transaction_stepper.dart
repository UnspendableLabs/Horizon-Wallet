import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_bloc.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transactions/fee_confirmation.dart';
import 'package:horizon/presentation/common/transactions/transaction_fee_input.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/domain/entities/compose_response.dart';

/// Represents the return type for step builders, containing both a title and widgets
class StepContent {
  final String title;
  final List<Widget> widgets;

  const StepContent({
    required this.title,
    required this.widgets,
  });
}

/// A transaction stepper widget that handles the UI for transaction flows.
/// Includes three steps: inputs, confirmation, and submission.
class TransactionStepper<T, R> extends StatefulWidget {
  /// Widget builder for transaction inputs (first step)
  /// Receives balances, data, loading state and error message - all extracted from the state
  /// Returns a StepContent with title and widgets
  final StepContent Function(
    MultiAddressBalance balances,
    FeeEstimates feeEstimates,
    FeeOption feeOption,
    T? data,
  ) buildFormStep;

  /// Widget builder for transaction confirmation (second step)
  /// Receives balances, data and error message - all extracted from the state
  /// Returns a StepContent with title and widgets
  final StepContent Function(ComposeStateSuccess<R> composeState)
      buildConfirmationStep;

  /// Widget builder for transaction submission (third step)
  /// This step uses pattern matching directly so it needs the state
  /// Returns a StepContent with title and widgets
  final StepContent Function(
    MultiAddressBalance balances,
    FeeEstimates feeEstimates,
    FeeOption feeOption,
    T? data,
  ) buildSubmissionStep;

  /// Callback when back button is pressed at the first step
  final VoidCallback onBack;

  /// Callbacks for each step's "Next" button
  final VoidCallback onFormStepNext;
  final VoidCallback onConfirmationStepNext;
  final VoidCallback onSubmissionStepNext;

  /// Callback for when a fee option is selected
  final void Function(FeeOption) onFeeOptionSelected;

  /// The transaction state
  final TransactionState<T, R> state;

  /// Whether the next button should be enabled
  final bool nextButtonEnabled;

  /// Whether to show the back button
  final bool showBackButton;

  /// Form key for the first step
  final GlobalKey<FormState> formKey;

  // Default button texts for the three steps
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
    required this.onBack,
    required this.state,
    required this.nextButtonEnabled,
    required this.onFormStepNext,
    required this.onConfirmationStepNext,
    required this.onSubmissionStepNext,
    required this.onFeeOptionSelected,
    this.showBackButton = true,
  });

  @override
  State<TransactionStepper<T, R>> createState() =>
      _TransactionStepperState<T, R>();
}

class _TransactionStepperState<T, R> extends State<TransactionStepper<T, R>> {
  // Step management is internal to the TransactionStepper
  int _currentStep = 0;

  void _handleNext() {
    // Execute the appropriate action for the current step
    switch (_currentStep) {
      case 0:
        // Validate form before proceeding to next step
        if (!widget.formKey.currentState!.validate()) {
          return; // Stop if validation fails
        }
        widget.onFormStepNext();
        break;
      case 1:
        widget.onConfirmationStepNext();
        break;
      case 2:
        widget.onSubmissionStepNext();
        break;
    }

    // Move to the next step if not on the last step
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _handleBack() {
    if (_currentStep > 0) {
      // Go back to the previous step
      setState(() {
        _currentStep--;
      });
    } else {
      // Exit the stepper if at the first step
      widget.onBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 500;

    if (widget.state.initial) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: widget.showBackButton
              ? AppIcons.iconButton(
                  context: context,
                  width: 32,
                  height: 32,
                  icon: AppIcons.backArrowIcon(
                      context: context,
                      width: 24,
                      height: 24,
                      fit: BoxFit.fitHeight),
                  onPressed: widget.onBack,
                )
              : null,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (widget.state.loadingFetch) {
      return _buildMainContent(
        context,
        isSmallScreen,
        true, // Show loading overlay
        null, // No error message
      );
    }

    if (widget.state.error != null) {
      return _buildMainContent(
        context,
        isSmallScreen,
        false, // No loading overlay
        widget.state.error,
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

  // Helper method to build the main stepper content
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
        return _buildLoadingOverlay(context);
      }

      // Inputs step - needs loading state too
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
        initial: () => _buildErrorContent(
          context,
          "Transaction composition required before confirmation",
          isSmallScreen,
        ),
        loading: () => _buildLoadingOverlay(context),
        error: (error) => _buildErrorContent(context, error, isSmallScreen),
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
      // Submission step
      if (balances == null || feeEstimates == null || feeOption == null) {
        return _buildLoadingOverlay(context);
      }
      stepContent =
          widget.buildSubmissionStep(balances, feeEstimates, feeOption, data);
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
        leading: widget.showBackButton
            ? AppIcons.iconButton(
                context: context,
                width: 32,
                height: 32,
                icon: AppIcons.backArrowIcon(
                    context: context,
                    width: 24,
                    height: 24,
                    fit: BoxFit.fitHeight),
                onPressed: _handleBack,
              )
            : null,
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
                                onPressed: widget.nextButtonEnabled
                                    ? _handleNext
                                    : null,
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

  // Helper method to build loading overlay
  Widget _buildLoadingOverlay(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.showBackButton
            ? AppIcons.iconButton(
                context: context,
                width: 32,
                height: 32,
                icon: AppIcons.backArrowIcon(
                    context: context,
                    width: 24,
                    height: 24,
                    fit: BoxFit.fitHeight),
                onPressed: _handleBack,
              )
            : null,
      ),
      body: const Center(
        child: CircularProgressIndicator(),
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
        leading: widget.showBackButton
            ? AppIcons.iconButton(
                context: context,
                width: 32,
                height: 32,
                icon: AppIcons.backArrowIcon(
                    context: context,
                    width: 24,
                    height: 24,
                    fit: BoxFit.fitHeight),
                onPressed: _handleBack,
              )
            : null,
      ),
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
