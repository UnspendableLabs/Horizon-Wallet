import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:fpdart/fpdart.dart';

abstract class TransactionRepository {
  Future<TransactionUnpacked> unpack(
      {required String raw, required HttpConfig httpConfig});
  Future<TransactionInfo> getInfo(
      {required String raw, required HttpConfig httpConfig});
}

extension TransactionRepositoryX on TransactionRepository {
  TaskEither<String, TransactionUnpacked> unpackT(
      {required String raw,
      required HttpConfig httpConfig,
      required Function(String error, StackTrace stack) onError}) {
    return TaskEither<String, TransactionUnpacked>.tryCatch(
      () => unpack(raw: raw, httpConfig: httpConfig),
      (e, stack) {
        print("\n\n\n");

        print(stack);

        return e.toString();
      },
    );
  }

  TaskEither<String, TransactionInfo> getInfoT(
      {required String raw,
      required HttpConfig httpConfig,
      required Function(String error, StackTrace stack) onError}) {
    return TaskEither<String, TransactionInfo>.tryCatch(
      () => getInfo(raw: raw, httpConfig: httpConfig),
      (e, stack) {
        print("\n\n\n");

        print(stack);

        return e.toString();
      },
    );
  }
}
