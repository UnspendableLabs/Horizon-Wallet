import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';
import 'package:horizon/domain/entities/http_config.dart';

abstract class TransactionRepository {
  Future<TransactionUnpacked> unpack(
      {required String raw, required HttpConfig httpConfig});
  Future<TransactionInfo> getInfo(
      {required String raw, required HttpConfig httpConfig});
}
