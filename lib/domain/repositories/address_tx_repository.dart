import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/issuance.dart';
import 'package:horizon/domain/entities/send.dart';
import 'package:horizon/domain/entities/transaction.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/network_error.dart';

abstract class AddressTxRepository {
  TaskEither<NetworkError, List<Send>> getSendsByAddress(
      String address, HttpConfig httpConfig);
  TaskEither<NetworkError, List<Issuance>> getIssuancesByAddress(
      String address, HttpConfig httpConfig);
  TaskEither<NetworkError, List<Transaction>> getTransactionsByAddress(
      String address, HttpConfig httpConfig);
}
