import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/address_info.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/network_error.dart';

abstract class BitcoinRepository {
  TaskEither<NetworkError, List<BitcoinTx>> getMempoolTransactions({
    required List<String> addresses,
    required HttpConfig httpConfig,
  });

  TaskEither<NetworkError, List<BitcoinTx>> getConfirmedTransactions({
    required List<String> addresses,
    required HttpConfig httpConfig,
  });

  TaskEither<NetworkError, List<BitcoinTx>> getConfirmedTransactionsPaginated({
    required String address,
    String? lastSeenTxid,
    required HttpConfig httpConfig,
  });

  TaskEither<NetworkError, List<BitcoinTx>> getTransactions({
    required List<String> addresses,
    required HttpConfig httpConfig,
  });

  TaskEither<NetworkError, BitcoinTx> getTransaction({
    required String txid,
    required HttpConfig httpConfig,
  });

  TaskEither<NetworkError, Map<String, double>> getFeeEstimates({
    required HttpConfig httpConfig,
  });

  TaskEither<NetworkError, String> getTransactionHex({
    required String txid,
    required HttpConfig httpConfig,
  });

  TaskEither<NetworkError, int> getBlockHeight({
    required HttpConfig httpConfig,
  });

  TaskEither<NetworkError, AddressInfo> getAddressInfo({
    required String address,
    required HttpConfig httpConfig,
  });
}
