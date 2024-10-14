import "package:horizon/domain/entities/dispenser.dart";
import "package:fpdart/fpdart.dart";
abstract class DispenserRepository {
  TaskEither<String, List<Dispenser>> getDispensersByAddress(String address);
}
