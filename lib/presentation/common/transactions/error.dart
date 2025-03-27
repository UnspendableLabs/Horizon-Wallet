import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/utils/app_icons.dart';

class TransactionError extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onErrorButtonAction;
  final String buttonText;

  const TransactionError(
      {super.key,
      required this.errorMessage,
      required this.onErrorButtonAction,
      required this.buttonText});

  @override
  Widget build(BuildContext context) {
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
              onPressed: onErrorButtonAction,
              buttonText: buttonText,
              isTransparent: true,
            ),
          ),
        ),
      ],
    );
  }
}
