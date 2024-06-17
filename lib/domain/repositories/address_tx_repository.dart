import 'package:horizon/domain/entities/issuance.dart';
import 'package:horizon/domain/entities/send.dart';
import 'package:horizon/domain/entities/transaction.dart';

abstract class AddressTxRepository {
  Future<List<Send>> getSendsByAddress(String address);
  Future<List<Issuance>> getIssuancesByAddress(String address);
  Future<List<Transaction>> getTransactionsByAddress(String address);
}
