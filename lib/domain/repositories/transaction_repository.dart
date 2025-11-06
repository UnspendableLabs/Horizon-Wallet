import 'package:horizon/domain/entities/network_error.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:fpdart/fpdart.dart';

abstract class TransactionRepository {
  TaskEither<NetworkError, TransactionUnpacked> unpack({
    required String raw,
    required HttpConfig httpConfig,
  });
  TaskEither<NetworkError, TransactionInfo> getInfo({
    required String raw,
    required HttpConfig httpConfig,
  });
}
