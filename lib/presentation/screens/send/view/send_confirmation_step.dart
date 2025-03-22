import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/screens/send/bloc/send_bloc.dart';

/// Second step of the send flow - super minimal
class SendConfirmationStep extends StatelessWidget {
  final List<MultiAddressBalance> balances;
  final SendData? data;

  const SendConfirmationStep({
    super.key,
    required this.balances,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    // Get asset info if available
    final assetName = balances.isNotEmpty ? balances.first.asset : null;

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
          // Transaction summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show confirmation details
                  _buildConfirmationDetail(
                      'Destination', data?.destinationAddress),
                  const SizedBox(height: 8),
                  _buildConfirmationDetail('Amount', data?.amount),
                  const SizedBox(height: 8),
                  // Show asset if available
                  if (assetName != null)
                    _buildConfirmationDetail('Asset', assetName),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build a confirmation detail row
  Widget _buildConfirmationDetail(String label, String? value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value ?? 'Not specified',
            style: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
