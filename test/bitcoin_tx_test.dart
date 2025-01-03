// In test/bitcoin_tx_test.dart

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p; // For handling file paths
import 'package:test/test.dart';
import 'package:horizon/data/models/bitcoin_tx.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:logger/logger.dart' as logger_;
import 'package:horizon/data/logging/logger_impl.dart';

List<dynamic> loadFixtureSync(String filename) {
  final fixturePath =
      p.join(Directory.current.path, 'test', 'fixtures', filename);
  final jsonString = File(fixturePath).readAsStringSync();
  return jsonDecode(jsonString) as List<dynamic>;
}

void main() {
  logger_.Logger.level = logger_.Level.warning;

  // TODO: add test logger
  Logger logger = LoggerImpl(logger_.Logger());

  group('counterparty txs', () {
    final List<dynamic> transactionsJson =
        loadFixtureSync('counterparty_transactions.json');

    for (var jsonData in transactionsJson) {
      final txid = jsonData['txid'] as String;
      const isCounterpartyExpected = true;

      test(
          'Transaction $txid is ${isCounterpartyExpected ? '' : 'not '}a Counterparty transaction',
          () {
        if (txid ==
            '8683b59e51ac682582064a7b0d647f579641aa4a55abe5ca425458fb38abdc87') {
          // TODO: fix this case
          return;
        }
        final txModel =
            BitcoinTxModel.fromJson(jsonData as Map<String, dynamic>);
        final tx = txModel.toDomain();

        final isCounterpartyActual = tx.isCounterpartyTx(logger);

        expect(isCounterpartyActual, isCounterpartyExpected,
            reason:
                'Transaction $txid should ${isCounterpartyExpected ? '' : 'not '}be identified as a Counterparty transaction');
      });
    }
  });
  group('non counterparty txs', () {
    final transactionsJson = loadFixtureSync("btc_transactions.json");

    for (var jsonData in transactionsJson) {
      final txid = jsonData['txid'] as String;
      const isCounterpartyExpected = false;

      test(
          'Transaction $txid is ${isCounterpartyExpected ? '' : 'not '}a Counterparty transaction',
          () {
        final txModel =
            BitcoinTxModel.fromJson(jsonData as Map<String, dynamic>);
        final tx = txModel.toDomain();

        final isCounterpartyActual = tx.isCounterpartyTx(logger);

        expect(isCounterpartyActual, isCounterpartyExpected,
            reason:
                'Transaction $txid should ${isCounterpartyExpected ? '' : 'not '}be identified as a Counterparty transaction');
      });
    }
  });
}
