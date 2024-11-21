import "package:horizon/domain/entities/imported_address.dart";
import "package:horizon/domain/entities/address.dart";

sealed class UnifiedAddress {}

class UImportedAddress extends UnifiedAddress {
  final ImportedAddress importedAddress;
  UImportedAddress(this.importedAddress);
}

class UAddress extends UnifiedAddress {
  final Address address;
  UAddress(this.address);
}
