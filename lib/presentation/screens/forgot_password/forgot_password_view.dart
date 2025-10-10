import 'package:flutter/material.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/presentation/screens/forgot_password/reset_wallet/reset_wallet_flow.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: AppIcons.backArrowIcon(
                  context: context,
                  width: 32,
                  height: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FORGOT PASSWORD?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Expanded(child: ResetWalletFlow()),
          const SizedBox(height: 24),
          // Mode Selection

          const SizedBox(height: 20),

          // Conditionally render dropdown based on mode

          const SizedBox(height: 20),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
