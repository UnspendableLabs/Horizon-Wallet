import 'package:horizon/domain/entities/transaction_info.dart';

abstract class TransactionLocalRepository {
  Future<void> insert(TransactionInfo transactionInfo);
  Future<void> delete(String txHas);
  Future<List<TransactionInfo>> getAllByAddresses(List<String> addresses);
  Future<List<TransactionInfo>> getAllByAccount(
    String account,
  );
  Future<void> deleteAllTransactions();
}
