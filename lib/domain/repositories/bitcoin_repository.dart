import "package:fpdart/fpdart.dart";
import 'package:horizon/domain/entities/network.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/failure.dart';
import 'package:horizon/domain/entities/address_info.dart';

sealed class Options {}

class Mainnet extends Options {}

class Testnet4 extends Options {}

class Custom extends Options {
  final String esplora;
  Custom({required this.esplora});
}

abstract class BitcoinRepository {
  Future<Either<Failure, List<BitcoinTx>>> getMempoolTransactions({
    required List<String> addresses,
    required Options options,
  });

  Future<Either<Failure, List<BitcoinTx>>> getConfirmedTransactions({
    required List<String> addresses,
    required Options options,
  });

  Future<Either<Failure, List<BitcoinTx>>> getConfirmedTransactionsPaginated({
    required String address,
    String? lastSeenTxid,
    required Options options,
  });

  Future<Either<Failure, List<BitcoinTx>>> getTransactions({
    required List<String> addresses,
    required Options options,
  });

  Future<Either<Failure, BitcoinTx>> getTransaction({
    required String txid,
    required Options options,
  });

  Future<Either<Failure, Map<String, double>>> getFeeEstimates({
    required Options options,
  });

  Future<Either<Failure, String>> getTransactionHex({
    required String txid,
    required Options options,
  });

  Future<Either<Failure, int>> getBlockHeight({
    required Options options,
  });

  Future<Either<Failure, AddressInfo>> getAddressInfo({
    required String address,
    required Options options,
  });
}
