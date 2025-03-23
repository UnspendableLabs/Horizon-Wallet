import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
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
      MultiAddressBalance? balances,
      FeeEstimates? feeEstimates,
      FeeOption? feeOption,
      T? data) buildInputsStep;

  /// Widget builder for transaction confirmation (second step)
  /// Receives balances, data and error message - all extracted from the state
  /// Returns a StepContent with title and widgets
  final StepContent Function(
      MultiAddressBalance? balances,
      FeeEstimates? feeEstimates,
      FeeOption? feeOption,
      T? data) buildConfirmationStep;

  /// Widget builder for transaction submission (third step)
  /// This step uses pattern matching directly so it needs the state
  /// Returns a StepContent with title and widgets
  final StepContent Function(
      MultiAddressBalance? balances,
      FeeEstimates? feeEstimates,
      FeeOption? feeOption,
      T? data) buildSubmissionStep;

  /// Callback when back button is pressed at the first step
  final VoidCallback onBack;

  /// Callbacks for each step's "Next" button
  final VoidCallback onInputsStepNext;
  final VoidCallback onConfirmationStepNext;
  final VoidCallback onSubmissionStepNext;

  /// Callback for when a fee option is selected
  final Function(FeeOption) onFeeOptionSelected;

  /// The transaction state
  final TransactionState<T> state;

  /// Whether the next button should be enabled
  final bool nextButtonEnabled;

  /// Whether to show the back button
  final bool showBackButton;

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
    required this.onFeeOptionSelected,
    required this.state,
    this.nextButtonEnabled = true,
    this.showBackButton = true,
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

    if (widget.state.loading) {
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
      // Inputs step - needs loading state too
      final inputsStepContent =
          widget.buildInputsStep(balances, feeEstimates, feeOption, data);

      // Add TransactionFeeInput to the widgets if we're on the first step
      final updatedWidgets = [
        ...inputsStepContent.widgets,
        commonHeightSizedBox,
        TransactionFeeInput(
          feeEstimates: feeEstimates,
          selectedFeeOption: feeOption ?? Medium(),
          onFeeOptionSelected: (feeOption) {
            // Create a FeeOptionSelected instance and add it to the bloc
            // final event = ;
            widget.onFeeOptionSelected(feeOption);
          },
        )
      ];

      stepContent = StepContent(
        title: inputsStepContent.title,
        widgets: updatedWidgets,
      );
    } else if (_currentStep == 1) {
      // Confirmation step
      stepContent =
          widget.buildConfirmationStep(balances, feeEstimates, feeOption, data);
    } else {
      // Submission step
      stepContent =
          widget.buildSubmissionStep(balances, feeEstimates, feeOption, data);
    }

    // Prepare error widget if there's an error
    Widget? errorWidget;
    if (errorMessage != null) {
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
              errorMessage,
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
