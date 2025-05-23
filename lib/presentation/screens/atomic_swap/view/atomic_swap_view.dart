import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/presentation/common/steps_indicator.dart';
import 'package:horizon/presentation/screens/atomic_swap/forms/choose_address.dart';
import 'package:horizon/presentation/screens/atomic_swap/forms/review_swap.dart';
import 'package:horizon/presentation/screens/atomic_swap/forms/swap_compose.dart';
import 'package:horizon/presentation/screens/atomic_swap/forms/token_selection.dart';
import 'package:horizon/utils/app_icons.dart';

class AtomicSwapView extends StatefulWidget {
  const AtomicSwapView({super.key});

  @override
  State<AtomicSwapView> createState() => _AtomicSwapViewState();
}

class _AtomicSwapViewState extends State<AtomicSwapView> {
  int _currentStep = 1;
  Widget _buildAppBar() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 20, 14, 4),
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  _currentStep == 1 ? context.pop() : setState(() {
                    _currentStep--;
                  });
                },
                icon: _currentStep == 1
                    ? AppIcons.closeIcon(
                        context: context,
                        width: 24,
                        height: 24,
                        fit: BoxFit.fitHeight,
                      )
                    : AppIcons.backArrowIcon(
                        context: context,
                        width: 24,
                        height: 24,
                        fit: BoxFit.fitHeight,
                      ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
          // TODO: control steps progress here 0.0 to 1.0
          child: StepsIndicator(progress: (_currentStep) / 4),
        )
      ],
    );
  }

  Widget _buildBody() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: _buildCurrentStep(),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return SwapFormTokenSelection(
          key: const ValueKey(1),
          onNextStep: (fromToken, toToken) {
            setState(() {
              _currentStep++;
            });
          },
        );
      case 2:
        return SwapFormChooseAddress(
          key: const ValueKey(2),
          onNextStep: (address) {
            setState(() {
              _currentStep++;
            });
          },
        );
      case 3:
        return SwapFormCompose(
          key: ValueKey(3),
          onNextStep: () {
            setState(() {
              _currentStep++;
            });
          },
        );
      case 4:
        return const SwapFormReviewStep(
          key: ValueKey(4),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}
