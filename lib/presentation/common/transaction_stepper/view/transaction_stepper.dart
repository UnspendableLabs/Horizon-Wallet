import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/utils/app_icons.dart';

/// A transaction stepper widget that handles the UI for transaction flows.
/// Includes three steps: inputs, confirmation, and submission.
class TransactionStepper extends StatefulWidget {
  /// Widget for transaction inputs (first step)
  final Widget transactionInputs;

  /// Widget for transaction confirmation (second step)
  final Widget transactionConfirmation;

  /// Widget for transaction submission (third step)
  final Widget transactionSubmission;

  /// Callback when back button is pressed at the first step
  final VoidCallback onBack;

  /// Callback when next button is pressed (different action per step)
  final List<VoidCallback> onNextActions;

  /// Loading state for the current step
  final bool isLoading;

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
    required this.transactionInputs,
    required this.transactionConfirmation,
    required this.transactionSubmission,
    required this.onBack,
    required this.onNextActions,
    this.isLoading = false,
    this.nextButtonEnabled = true,
    this.showBackButton = true,
  }) : assert(onNextActions.length == 3,
            'Must provide 3 next actions for each step');

  @override
  State<TransactionStepper> createState() => _TransactionStepperState();
}

class _TransactionStepperState extends State<TransactionStepper> {
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

    final steps = [
      widget.transactionInputs,
      widget.transactionConfirmation,
      widget.transactionSubmission,
    ];

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
              const SizedBox(height: 24),
              // Main content
              Expanded(
                child: steps[_currentStep],
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
          if (widget.isLoading)
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
