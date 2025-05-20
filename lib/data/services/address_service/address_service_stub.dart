import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/seed.dart';

class AddressServiceStub implements AddressService {
  Never _unsupported(String fn) =>
      throw UnimplementedError('$fn is not supported on this platform.');

  Future<AddressV2> deriveAddressWIP({
    required String path,
    required Seed seed,
    required Network network,
  }) =>
      Future.error(_unsupported('deriveAddressWIP'));

  Future<String> deriveAddressPrivateKeyWIP({
    required Bip32Path path,
    required Seed seed,
    required Network network,
  }) =>
      Future.error(_unsupported("deriveAddressPrivateKeyWIP"));

  @override
  Future<Address> deriveAddressSegwit({
    required String privKey,
    required String chainCodeHex,
    required String accountUuid,
    required String purpose,
    required String coin,
    required String account,
    required String change,
    required int index,
  }) =>
      Future.error(_unsupported('deriveAddressSegwit'));

  @override
  Future<Address> deriveAddressFreewallet({
    required AddressType type,
    required dynamic root,
    required String accountUuid,
    required String account,
    required String change,
    required int index,
  }) =>
      Future.error(_unsupported('deriveAddressFreewallet'));

  @override
  Future<List<Address>> deriveAddressSegwitRange({
    required String privKey,
    required String chainCodeHex,
    required String accountUuid,
    required String purpose,
    required String coin,
    required String account,
    required String change,
    required int start,
    required int end,
  }) =>
      Future.error(_unsupported('deriveAddressSegwitRange'));

  @override
  Future<List<Address>> deriveAddressFreewalletRange({
    required AddressType type,
    required String privKey,
    required String chainCodeHex,
    required String accountUuid,
    required String account,
    required String change,
    required int start,
    required int end,
  }) =>
      Future.error(_unsupported('deriveAddressFreewalletRange'));

  @override
  Future<String> deriveAddressPrivateKey({
    required String rootPrivKey,
    required String chainCodeHex,
    required String purpose,
    required String coin,
    required String account,
    required String change,
    required int index,
    required ImportFormat importFormat,
  }) =>
      Future.error(_unsupported('deriveAddressPrivateKey'));

  @override
  Future<String> getAddressWIFFromPrivateKey({
    required String rootPrivKey,
    required String chainCodeHex,
    required String purpose,
    required String coin,
    required String account,
    required String change,
    required int index,
    required ImportFormat importFormat,
  }) =>
      Future.error(_unsupported('getAddressWIFFromPrivateKey'));
}

AddressService createAddressServiceImpl() =>
    AddressServiceStub();
