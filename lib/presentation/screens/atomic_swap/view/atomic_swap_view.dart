import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/presentation/common/steps_indicator.dart';
import 'package:horizon/presentation/screens/atomic_swap/forms/token_selection.dart';
import 'package:horizon/utils/app_icons.dart';

class AtomicSwapView extends StatefulWidget {
  final int _currentStep = 0;
  const AtomicSwapView({super.key});

  @override
  State<AtomicSwapView> createState() => _AtomicSwapViewState();
}

class _AtomicSwapViewState extends State<AtomicSwapView> {
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
                  context.pop();
                },
                icon: AppIcons.closeIcon(
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
          child: const StepsIndicator(progress: 0.5),
        )
      ],
    );
  }

  Widget _buildBody() {
    switch (widget._currentStep) {
      case 0:
        return const TokenSelectionForm();
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
          _buildBody(),
        ],
      ),
    );
  }
}
