import "package:fpdart/fpdart.dart";
import 'package:horizon/domain/entities/unified_address.dart';
import 'package:horizon/domain/repositories/unified_address_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';

class UnifiedAddressRepositoryImpl implements UnifiedAddressRepository {
  final AddressRepository addressRepository;
  final ImportedAddressRepository importedAddressRepository;

  const UnifiedAddressRepositoryImpl({
    required this.addressRepository,
    required this.importedAddressRepository,
  });

  @override
  TaskEither<String, UnifiedAddress> get(String address) {
    return TaskEither.tryCatch(() async {
      return await _getUnifiedAddress(address);
    }, (e, s) {
      return e.toString();
    });
  }

  _getUnifiedAddress(String address) async {
    var address_ = await addressRepository.getAddress(address);
    var importedAddress =
        await importedAddressRepository.getImportedAddress(address);
    if (address_ != null) {
      return UAddress(address_);
    } else if (importedAddress != null) {
      return UImportedAddress(importedAddress);
    } else {
      throw UAddressNotFoundError(address);
    }
  }
}

class UAddressNotFoundError extends Error {
  final String address;
  UAddressNotFoundError(this.address);
}
