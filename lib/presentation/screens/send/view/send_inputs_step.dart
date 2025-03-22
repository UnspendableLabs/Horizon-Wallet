import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/screens/send/bloc/send_bloc.dart';

/// First step of the send flow - super minimal
class SendInputsStep extends StatelessWidget {
  final List<MultiAddressBalance> balances;
  final SendData? data;
  final String? assetName;

  const SendInputsStep({
    super.key,
    required this.balances,
    this.data,
    this.assetName,
  });

  @override
  Widget build(BuildContext context) {
    // Check if we have balances
    final hasBalances = balances.isNotEmpty;

    // Safely get form values
    final destinationAddress = data?.destinationAddress ?? '';
    final amount = data?.amount ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Send ${assetName ?? "Asset"}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // Use controllers instead of initialValue for text fields
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Destination Address',
              border: OutlineInputBorder(),
            ),
            // Disable the field during loading
            controller: TextEditingController(text: destinationAddress),
          ),
          const SizedBox(height: 16),
          // Only show the amount field if we have balances
          if (hasBalances)
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Amount (${assetName ?? "Asset"})',
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              controller: TextEditingController(text: amount),
            ),
          // Show error message if there is one
        ],
      ),
    );
  }
}
