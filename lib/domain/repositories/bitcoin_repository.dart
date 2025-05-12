import "package:fpdart/fpdart.dart";
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/failure.dart';
import 'package:horizon/domain/entities/address_info.dart';
import 'package:horizon/domain/entities/http_config.dart';

abstract class BitcoinRepository {
  Future<Either<Failure, List<BitcoinTx>>> getMempoolTransactions({
    required List<String> addresses,
    required HttpConfig httpConfig,
  });

  Future<Either<Failure, List<BitcoinTx>>> getConfirmedTransactions({
    required List<String> addresses,
    required HttpConfig httpConfig,
  });

  Future<Either<Failure, List<BitcoinTx>>> getConfirmedTransactionsPaginated({
    required String address,
    String? lastSeenTxid,
    required HttpConfig httpConfig,
  });

  Future<Either<Failure, List<BitcoinTx>>> getTransactions({
    required List<String> addresses,
    required HttpConfig httpConfig,
  });

  Future<Either<Failure, BitcoinTx>> getTransaction({
    required String txid,
    required HttpConfig httpConfig,
  });

  Future<Either<Failure, Map<String, double>>> getFeeEstimates({
    required HttpConfig httpConfig,
  });

  Future<Either<Failure, String>> getTransactionHex({
    required String txid,
    required HttpConfig httpConfig,
  });

  Future<Either<Failure, int>> getBlockHeight({
    required HttpConfig httpConfig,
  });

  Future<Either<Failure, AddressInfo>> getAddressInfo({
    required String address,
    required HttpConfig httpConfig,
  });
}
