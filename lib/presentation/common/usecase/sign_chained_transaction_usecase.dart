import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/services/transaction_service.dart';

class SignTransactionException implements Exception {
  final String message;
  SignTransactionException(
      [this.message =
          'An error occurred during the sign transaction process.']);
}

class SignChainedTransactionUseCase {
  final TransactionService transactionService;

  SignChainedTransactionUseCase({
    required this.transactionService,
  });

  Future<String> call({
    required String password,
    required String source,
    required String rawtransaction,
    required DecodedTx prevDecodedTransaction,
    required String addressPrivKey,
  }) async {
    try {
      // TODO: construct and pass utxoMap outside of this usecase and pass it in as a parameter
      final vout = prevDecodedTransaction.vout
          .firstWhere((vout) => vout.scriptPubKey.address == source);
      final utxosToSign = [
        Utxo(
            txid: prevDecodedTransaction.txid,
            vout: vout.n,
            height: null,
            value: (vout.value * 100000000).toInt(),
            address: vout.scriptPubKey.address!)
      ];

      final Map<String, Utxo> utxoMap = {for (var e in utxosToSign) e.txid: e};

      // Sign Transaction
      final signedTransaction = await transactionService.signTransaction(
        rawtransaction,
        addressPrivKey,
        source,
        utxoMap,
      );

      return signedTransaction;
    } catch (e) {
      throw SignTransactionException('Failed to sign transaction: $e');
    }
  }
}
