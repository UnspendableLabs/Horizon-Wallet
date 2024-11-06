import "package:fpdart/fpdart.dart";
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart';
import 'package:horizon/domain/entities/failure.dart';
import 'package:horizon/domain/entities/address_info.dart';

abstract class BitcoinRepository {
  Future<Either<Failure, List<BitcoinTx>>> getMempoolTransactions(
      List<String> addresses);
  Future<Either<Failure, List<BitcoinTx>>> getConfirmedTransactions(
      List<String> addresses);
  Future<Either<Failure, List<BitcoinTx>>> getConfirmedTransactionsPaginated(
      String address, String? lastSeenTxid);
  Future<Either<Failure, List<BitcoinTx>>> getTransactions(
      List<String> addresses);
  Future<Either<Failure, BitcoinTx>> getTransaction(String txid);
  Future<Either<Failure, Map<String, double>>> getFeeEstimates();
  Future<Either<Failure, String>> getTransactionHex(String txid);
  Future<Either<Failure, int>> getBlockHeight();
  Future<Either<Failure, AddressInfo>> getAddressInfo(String address);
  Future<Either<Failure, BitcoinDecodedTx>> decodeRawTransaction(String hexString);
}
