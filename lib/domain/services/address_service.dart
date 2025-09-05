import 'package:fpdart/fpdart.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/seed.dart';
import 'package:horizon/domain/entities/network.dart';

enum AddressType { bech32, legacy }

abstract class AddressService {
  // TODO: this should return address V2
  Future<Map<AddressV2Type, AddressV2>> deriveAddressWIP({
    required String path,
    required Seed seed,
    required Network network,
    required Set<AddressV2Type> addressKinds,
  });

  Future<String> deriveAddressPrivateKeyWIP({
    required Bip32Path path,
    required Seed seed,
    required Network network,
  });

  Future<Address> deriveAddressSegwit(
      {required String privKey,
      required String chainCodeHex,
      required String accountUuid,
      required String purpose,
      required String coin,
      required String account,
      required String change,
      required int index});
  Future<Address> deriveAddressFreewallet(
      {required AddressType type,
      required dynamic root,
      required String accountUuid,
      required String account,
      required String change,
      required int index});
  Future<List<Address>> deriveAddressSegwitRange(
      {required String privKey,
      required String chainCodeHex,
      required String accountUuid,
      required String purpose,
      required String coin,
      required String account,
      required String change,
      required int start,
      required int end});
  Future<List<Address>> deriveAddressFreewalletRange(
      {required AddressType type,
      required String privKey,
      required String chainCodeHex,
      required String accountUuid,
      required String account,
      required String change,
      required int start,
      required int end});
  Future<String> deriveAddressPrivateKey({
    required String rootPrivKey,
    required String chainCodeHex,
    required String purpose,
    required String coin,
    required String account,
    required String change,
    required int index,
    required ImportFormat importFormat,
  });
  Future<String> getAddressWIFFromPrivateKey({
    required String rootPrivKey,
    required String chainCodeHex,
    required String purpose,
    required String coin,
    required String account,
    required String change,
    required int index,
    required ImportFormat importFormat,
  });
}

extension AddressServiceX on AddressService {
  TaskEither<String, Map<AddressV2Type, AddressV2>> deriveAddressWIPT({
    required String path,
    required Seed seed,
    required Network network,
    required Set<AddressV2Type> addressKinds,
  }) {
    return TaskEither.tryCatch(
      () => deriveAddressWIP(
          addressKinds: addressKinds, path: path, seed: seed, network: network),
      (e_, _) => "error deriving address",
    );
  }

  TaskEither<String, String> deriveAddressPrivateKeyWIPT({
    required Bip32Path path,
    required Seed seed,
    required Network network,
  }) {
    return TaskEither.tryCatch(
      () =>
          deriveAddressPrivateKeyWIP(path: path, seed: seed, network: network),
      (e, _) => "error deriving address private key",
    );
  }
}
