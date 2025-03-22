import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/screens/send/bloc/send_bloc.dart';

/// Third step of the send flow
class SendSubmissionStep extends StatelessWidget {
  final List<MultiAddressBalance> balances;
  final SendData? data;

  const SendSubmissionStep({
    super.key,
    required this.balances,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Submission',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
