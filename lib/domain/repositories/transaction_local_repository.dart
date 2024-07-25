import 'package:horizon/domain/entities/transaction_info.dart';

abstract class TransactionLocalRepository {
  Future<void> insert(TransactionInfo transactionInfo);
  Future<List<TransactionInfo>> getAllByAccount(String account);
}
