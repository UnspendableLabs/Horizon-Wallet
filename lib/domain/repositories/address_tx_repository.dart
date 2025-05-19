import 'package:horizon/domain/entities/issuance.dart';
import 'package:horizon/domain/entities/send.dart';
import 'package:horizon/domain/entities/transaction.dart';
import 'package:horizon/domain/entities/http_config.dart';

abstract class AddressTxRepository {
  Future<List<Send>> getSendsByAddress(String address, HttpConfig httpConfig);
  Future<List<Issuance>> getIssuancesByAddress(
      String address, HttpConfig httpConfig);
  Future<List<Transaction>> getTransactionsByAddress(
      String address, HttpConfig httpConfig);
}
