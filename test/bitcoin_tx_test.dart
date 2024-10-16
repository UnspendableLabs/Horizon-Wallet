// In test/bitcoin_tx_test.dart

import 'dart:convert';
import 'dart:io';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p; // For handling file paths
import 'package:test/test.dart';
import 'package:horizon/data/models/bitcoin_tx.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:logger/logger.dart' as _logger;
import 'package:horizon/data/logging/logger_impl.dart';

List<dynamic> loadFixtureSync(String filename) {
  final fixturePath =
      p.join(Directory.current.path, 'test', 'fixtures', filename);
  final jsonString = File(fixturePath).readAsStringSync();
  return jsonDecode(jsonString) as List<dynamic>;
}

void main() {
  _logger.Logger.level = _logger.Level.warning;

  // TODO: add test logger
  Logger logger = LoggerImpl(_logger.Logger());

  group('counterparty txs', () {
    final List<dynamic> transactionsJson =
        loadFixtureSync('counterparty_transactions.json');

    for (var jsonData in transactionsJson) {
      final txid = jsonData['txid'] as String;
      const isCounterpartyExpected = true;

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
