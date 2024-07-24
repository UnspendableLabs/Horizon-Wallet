import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';

// TODO: maybe split out into remote / local

abstract class TransactionRepository {
  Future<TransactionUnpacked> unpack(String raw);
  Future<TransactionInfo> getInfo(String raw);
  Future<void> insert(TransactionInfo transactionInfo);
  Future<List> getAllByAccount(String account);
}
