import "package:fpdart/fpdart.dart";
import "package:horizon/domain/entities/unified_address.dart";

abstract class UnifiedAddressRepository {
  TaskEither<String, UnifiedAddress> get(String address);
}
