import 'dart:convert';
import "package:get_it/get_it.dart";
import 'package:horizon/domain/services/transaction_service.dart';

abstract class ComposeResponse {
  String get psbt;
  String get rawtransaction;
  int get btcFee;
  SignedTxEstimatedSize get signedTxEstimatedSize;
}

class SignedTxEstimatedSize {
  final int virtualSize;
  final int adjustedVirtualSize;
  final int sigopsCount;

  SignedTxEstimatedSize({
    required this.virtualSize,
    required this.adjustedVirtualSize,
    required this.sigopsCount,
  });
}

extension ComposeResponseHex on ComposeResponse {
  String get psbtHex => base64
      .decode(psbt)
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
}

extension ComposeResponseCountInputs on ComposeResponse {
  int numInputs({
    TransactionService? transactionService,
  }) =>
      (transactionService ?? GetIt.I<TransactionService>()).countInputs(
        rawtransaction: rawtransaction,
      );
}
