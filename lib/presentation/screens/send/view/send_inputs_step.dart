import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/send/bloc/send_state.dart';

/// First step of the send flow - super minimal
class SendInputsStep extends StatelessWidget {
  final SendState state;

  const SendInputsStep({
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
            'Send',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Destination Address',
              border: OutlineInputBorder(),
            ),
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
