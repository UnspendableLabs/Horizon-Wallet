import 'package:horizon/domain/entities/transaction_info.dart';

abstract class TransactionLocalRepository {
  Future<void> insertVerbose(TransactionInfoVerbose transactionInfo);
  Future<List<TransactionInfoVerbose>> getAllByAddressesVerbose(
      List<String> addresses);
  Future<List<TransactionInfoVerbose>> getAllByAccountVerbose(String account);
  Future<List<TransactionInfoVerbose>> getAllByAccountAfterDateVerbose(
      String account, DateTime date);
}
