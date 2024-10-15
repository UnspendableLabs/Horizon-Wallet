import 'package:horizon/domain/entities/transaction_info.dart';

abstract class TransactionLocalRepository {
  Future<void> insert(TransactionInfo transactionInfo);
  Future<List<TransactionInfo>> getAllByAddresses(
      List<String> addresses);
  Future<List<TransactionInfo>> getAllByAccount(String account);
  Future<List<TransactionInfo>> getAllByAccountAfterDate(
      String account, DateTime date);
}
