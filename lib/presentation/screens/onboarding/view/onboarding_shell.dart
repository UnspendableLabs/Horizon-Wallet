import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

class OnboardingShell extends StatefulWidget {
  final List<Widget> steps;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final String nextButtonText;
  final String backButtonText;
  final bool isLoading;
  final bool nextButtonEnabled;

  const OnboardingShell({
    super.key,
    required this.steps,
    required this.onBack,
    required this.onNext,
    required this.nextButtonText,
    required this.backButtonText,
    this.isLoading = false,
    this.nextButtonEnabled = true,
  });

  @override
  State<OnboardingShell> createState() => _OnboardingShellState();
}

class _OnboardingShellState extends State<OnboardingShell> {
  int _currentStep = 0;

  void _handleStepContinue() {
    widget.onNext();
    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _handleStepBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backdropBackgroundColor = isDarkMode
        ? darkThemeBackgroundColor
        : lightThemeBackgroundColorTopGradiant;

    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 500;

    final shellContent = Scaffold(
      backgroundColor: backdropBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: _handleStepBack,
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Step indicators
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: isWideScreen ? 30 : 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.steps.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index <= _currentStep
                              ? (isDarkMode ? Colors.white : Colors.black)
                              : (isDarkMode
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.3)),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),
              // Main content
              Expanded(
                child: widget.steps[_currentStep],
              ),
              // Bottom buttons
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 30, horizontal: isWideScreen ? 30 : 16),
                child: Row(
                  children: [
                    Expanded(
                      child: HorizonOutlinedButton(
                        isTransparent: false,
                        isDarkMode: isDarkMode,
                        onPressed: widget.nextButtonEnabled
                            ? _handleStepContinue
                            : null,
                        buttonText: _currentStep == widget.steps.length - 1
                            ? widget.nextButtonText
                            : 'Continue',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );

    if (!isWideScreen) {
      return shellContent;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 500,
          height: 812,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: shellContent,
          ),
        ),
      ),
    );
  }
}
