import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transactions/transaction_fee_input.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/domain/entities/fee_option.dart';

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
class TransactionStepper<T> extends StatefulWidget {
  /// Widget builder for transaction inputs (first step)
  /// Receives balances, data, loading state and error message - all extracted from the state
  /// Returns a StepContent with title and widgets
  final StepContent Function(
      SharedTransactionState? sharedTransactionState, T? data) buildInputsStep;

  /// Widget builder for transaction confirmation (second step)
  /// Receives balances, data and error message - all extracted from the state
  /// Returns a StepContent with title and widgets
  final StepContent Function(
          SharedTransactionState? sharedTransactionState, T? data)
      buildConfirmationStep;

  /// Widget builder for transaction submission (third step)
  /// This step uses pattern matching directly so it needs the state
  /// Returns a StepContent with title and widgets
  final StepContent Function(
          SharedTransactionState? sharedTransactionState, T? data)
      buildSubmissionStep;

  /// Callback when back button is pressed at the first step
  final VoidCallback onBack;

  /// Callbacks for each step's "Next" button
  final VoidCallback onInputsStepNext;
  final VoidCallback onConfirmationStepNext;
  final VoidCallback onSubmissionStepNext;

  /// The transaction state
  final TransactionState<T> state;

  /// Whether the next button should be enabled
  final bool nextButtonEnabled;

  /// Whether to show the back button
  final bool showBackButton;

  /// Callback for when the user selects a fee option
  final Function(FeeOption)? onFeeOptionSelected;

  // Default button texts for the three steps
  static const List<String> defaultButtonTexts = [
    'Review Transaction',
    'Sign and Submit',
  ];

  const TransactionStepper({
    super.key,
    required this.buildInputsStep,
    required this.buildConfirmationStep,
    required this.buildSubmissionStep,
    required this.onBack,
    required this.onInputsStepNext,
    required this.onConfirmationStepNext,
    required this.onSubmissionStepNext,
    required this.state,
    this.nextButtonEnabled = true,
    this.showBackButton = true,
    this.onFeeOptionSelected,
  });

  @override
  State<TransactionStepper<T>> createState() => _TransactionStepperState<T>();
}

class _TransactionStepperState<T> extends State<TransactionStepper<T>> {
  // Step management is internal to the TransactionStepper
  int _currentStep = 0;

  void _handleNext() {
    // Execute the appropriate action for the current step
    switch (_currentStep) {
      case 0:
        widget.onInputsStepNext();
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

    // Use pattern matching to handle different states
    return widget.state.when(
      // Initial state - show loading indicator
      initial: () => Scaffold(
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
      ),

      // Loading state - show content with loading overlay
      loading: () => _buildMainContent(
        context,
        isSmallScreen,
        true, // Show loading overlay
        null, // No error message
      ),

      // Error state - show content with error message
      error: (message) => _buildMainContent(
        context,
        isSmallScreen,
        false, // No loading overlay
        message, // Show error message
      ),

      // Success state - show content with data
      success: (sharedTransactionState, data) => _buildMainContent(
        context,
        isSmallScreen,
        false, // No loading overlay
        null, // No error message
        sharedTransactionState: sharedTransactionState,
        data: data,
      ),
    );
  }

  // Helper method to build the main stepper content
  Widget _buildMainContent(
    BuildContext context,
    bool isSmallScreen,
    bool showLoadingOverlay,
    String? errorMessage, {
    SharedTransactionState? sharedTransactionState,
    T? data,
  }) {
    final extractedErrorMsg = widget.state.maybeWhen(
      error: (message) => message,
      orElse: () => errorMessage,
    );

    // Get the appropriate StepContent for the current step
    StepContent stepContent;

    if (_currentStep == 0) {
      // Inputs step - needs loading state too
      final inputsStepContent =
          widget.buildInputsStep(sharedTransactionState, data);

      // Add TransactionFeeInput to the widgets if we're on the first step
      final updatedWidgets = [
        ...inputsStepContent.widgets,
        commonHeightSizedBox,
        if (sharedTransactionState != null)
          TransactionFeeInput(
            feeEstimates: sharedTransactionState.feeEstimates,
            selectedFeeOption: sharedTransactionState.feeOption ?? Medium(),
            onFeeOptionSelected: (feeOption) {
              // // Update the shared transaction state with the new fee option
              // final updatedState = sharedTransactionState.copyWith(
              //   feeOption: feeOption,
              // );

              // // Call the onFeeOptionSelected callback if available
              // widget.onFeeOptionSelected?.call(feeOption);
            },
          )
      ];

      stepContent = StepContent(
        title: inputsStepContent.title,
        widgets: updatedWidgets,
      );
    } else if (_currentStep == 1) {
      // Confirmation step
      stepContent = widget.buildConfirmationStep(sharedTransactionState, data);
    } else {
      // Submission step
      stepContent = widget.buildSubmissionStep(sharedTransactionState, data);
    }

    // Prepare error widget if there's an error
    Widget? errorWidget;
    if (extractedErrorMsg != null) {
      errorWidget = Container(
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
              extractedErrorMsg,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

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
                  child: Column(
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
}
