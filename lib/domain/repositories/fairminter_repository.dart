import "package:fpdart/fpdart.dart";
import "package:horizon/domain/entities/fairminter.dart";

abstract class FairminterRepository {
  TaskEither<String, List<Fairminter>> getAllFairminters();
}
