import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/send/bloc/send_state.dart';

/// Second step of the send flow - super minimal
class SendConfirmationStep extends StatelessWidget {
  final SendState state;

  const SendConfirmationStep({
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
            'Confirm Transaction',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('This is a placeholder for transaction details.'),
                  SizedBox(height: 16),
                  Text('Fee: 1000 sats'),
                ],
              ),
            ),
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
