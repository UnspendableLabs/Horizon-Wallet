import "package:horizon/domain/entities/dispenser.dart";
import "package:fpdart/fpdart.dart";
import 'package:horizon/domain/entities/http_config.dart';

abstract class DispenserRepository {
  TaskEither<String, List<Dispenser>> getDispensersByAddress(
      String address, HttpConfig httpConfig);
}
