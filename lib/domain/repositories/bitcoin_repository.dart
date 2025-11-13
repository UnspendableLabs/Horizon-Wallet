import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/address_info.dart';
import 'package:horizon/domain/entities/http_config.dart';

abstract class BitcoinRepository {
  Future<List<BitcoinTx>> getMempoolTransactions({
    required List<String> addresses,
    required HttpConfig httpConfig,
  });

  Future<List<BitcoinTx>> getConfirmedTransactions({
    required List<String> addresses,
    required HttpConfig httpConfig,
  });

  Future<List<BitcoinTx>> getConfirmedTransactionsPaginated({
    required String address,
    String? lastSeenTxid,
    required HttpConfig httpConfig,
  });

  Future<List<BitcoinTx>> getTransactions({
    required List<String> addresses,
    required HttpConfig httpConfig,
  });

  Future<BitcoinTx> getTransaction({
    required String txid,
    required HttpConfig httpConfig,
  });

  Future<Map<String, double>> getFeeEstimates({
    required HttpConfig httpConfig,
  });

  Future<String> getTransactionHex({
    required String txid,
    required HttpConfig httpConfig,
  });

  Future<int> getBlockHeight({
    required HttpConfig httpConfig,
  });

  Future<AddressInfo> getAddressInfo({
    required String address,
    required HttpConfig httpConfig,
  });
}
