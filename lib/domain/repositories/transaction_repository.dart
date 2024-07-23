import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';

abstract class TransactionRepository {
  Future<TransactionUnpacked> unpack(String raw);
  Future<TransactionInfo> getInfo(String raw);
  Future<void> insert(TransactionInfo transactionInfo);
}
