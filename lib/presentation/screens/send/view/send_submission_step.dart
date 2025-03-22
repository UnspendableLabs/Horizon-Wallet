import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/send/bloc/send_state.dart';

/// Third step of the send flow - super minimal
class SendSubmissionStep extends StatelessWidget {
  final SendState state;

  const SendSubmissionStep({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sign & Submit',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Enter your password to sign and broadcast the transaction.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            enabled: !state.isLoading,
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                state.error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
