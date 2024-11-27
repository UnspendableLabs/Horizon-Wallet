import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/transaction_info_mempool.dart';

abstract class TransactionInfoRepository {
  TaskEither<String, TransactionInfoMempool> getTransactionInfo(String txid);
}
