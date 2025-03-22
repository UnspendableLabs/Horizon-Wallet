import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/utils/app_icons.dart';

/// A transaction stepper widget that handles the UI for transaction flows.
/// Includes three steps: inputs, confirmation, and submission.
class TransactionStepper<T> extends StatefulWidget {
  /// Widget builder for transaction inputs (first step)
  /// Receives balances, data, loading state and error message - all extracted from the state
  final Widget Function(List<MultiAddressBalance> balances, T? data,
      bool isLoading, String? errorMessage) buildInputsStep;

  /// Widget builder for transaction confirmation (second step)
  /// Receives balances, data and error message - all extracted from the state
  final Widget Function(
          List<MultiAddressBalance> balances, T? data, String? errorMessage)
      buildConfirmationStep;

  /// Widget builder for transaction submission (third step)
  /// This step uses pattern matching directly so it needs the state
  final Widget Function(List<MultiAddressBalance> balances, T? data)
      buildSubmissionStep;

  /// Callback when back button is pressed at the first step
  final VoidCallback onBack;

  /// Callback when next button is pressed (different action per step)
  final List<VoidCallback> onNextActions;

  /// The transaction state
  final TransactionState<T> state;

  /// Whether the next button should be enabled
  final bool nextButtonEnabled;

  /// Whether to show the back button
  final bool showBackButton;

  // Default button texts for the three steps
  static const List<String> defaultButtonTexts = [
    'CONTINUE',
    'REVIEW',
    'SIGN & SUBMIT'
  ];

  const TransactionStepper({
    super.key,
    required this.buildInputsStep,
    required this.buildConfirmationStep,
    required this.buildSubmissionStep,
    required this.onBack,
    required this.onNextActions,
    required this.state,
    this.nextButtonEnabled = true,
    this.showBackButton = true,
  }) : assert(onNextActions.length == 3,
            'Must provide 3 next actions for each step');

  @override
  State<TransactionStepper<T>> createState() => _TransactionStepperState<T>();
}

class _TransactionStepperState<T> extends State<TransactionStepper<T>> {
  // Step management is internal to the TransactionStepper
  int _currentStep = 0;

  void _handleNext() {
    // Execute the action for the current step
    widget.onNextActions[_currentStep]();

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
      success: (balances, data) => _buildMainContent(
        context,
        isSmallScreen,
        false, // No loading overlay
        null, // No error message
        balances: balances,
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
    List<MultiAddressBalance> balances = const [],
    T? data,
  }) {
    // Extract all state information for the builder functions
    final isLoading = widget.state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    final extractedErrorMsg = widget.state.maybeWhen(
      error: (message) => message,
      orElse: () => errorMessage,
    );

    // Get the appropriate widget for the current step
    Widget currentStepWidget;

    if (_currentStep == 0) {
      // Inputs step - needs loading state too
      currentStepWidget =
          widget.buildInputsStep(balances, data, isLoading, extractedErrorMsg);
    } else if (_currentStep == 1) {
      // Confirmation step
      currentStepWidget =
          widget.buildConfirmationStep(balances, data, extractedErrorMsg);
    } else {
      // Submission step - pass the whole state
      currentStepWidget = widget.buildSubmissionStep(balances, data);
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

              // Error display at top if there is an error
              if (errorWidget != null) errorWidget,

              // Main content
              Expanded(
                child: currentStepWidget,
              ),
              // Bottom buttons
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 30, horizontal: isSmallScreen ? 20 : 40),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 64,
                        child: HorizonOutlinedButton(
                          isTransparent: false,
                          onPressed:
                              widget.nextButtonEnabled ? _handleNext : null,
                          buttonText: TransactionStepper
                              .defaultButtonTexts[_currentStep],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
