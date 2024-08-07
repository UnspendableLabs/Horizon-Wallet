import "package:fpdart/fpdart.dart";
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/failure.dart';

abstract class BitcoinRepository {
  Future<Either<Failure, List<BitcoinTx>>> getMempoolTransactions(
      List<String> addresses);

  Future<Either<Failure, BitcoinTx>> getTransaction(String txid);
}