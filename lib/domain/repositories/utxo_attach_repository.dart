import 'package:horizon/domain/entities/utxo_attach.dart';
import "package:fpdart/fpdart.dart";

abstract class UtxoAttachRepository {
  Future<void> create(UtxoAttach value);
}

extension UtxoAttachRepositoryX on UtxoAttachRepository {
  TaskEither<String, void> createTE(UtxoAttach value) {
    return TaskEither.tryCatch(
      () => create(value),
      (error, stackTrace) => error.toString(),
    );
  }
}
