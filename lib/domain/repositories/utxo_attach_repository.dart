import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/utxo_attach.dart';
import "package:fpdart/fpdart.dart";

abstract class UtxoAttachRepository {
  Future<void> create(UtxoAttach value);
  Future<UtxoAttach?> getByID(UtxoID utxoID);
}

extension UtxoAttachRepositoryX on UtxoAttachRepository {
  TaskEither<String, void> createTE(UtxoAttach value) {
    return TaskEither.tryCatch(
      () => create(value),
      (error, stackTrace) => error.toString(),
    );
  }

  TaskEither<String, UtxoAttach?> getByIDTE(UtxoID utxoID) {
    return TaskEither.tryCatch(
      () => getByID(utxoID),
      (error, stackTrace) => error.toString(),
    );
  }
}
