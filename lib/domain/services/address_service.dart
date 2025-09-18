import 'package:fpdart/fpdart.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/seed.dart';
import 'package:horizon/domain/entities/network.dart';

enum AddressType { bech32, legacy }

abstract class AddressService {
  // TODO: this should return address V2
  Future<Map<AddressV2Type, AddressV2>> deriveAddress({
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
}

extension AddressServiceX on AddressService {
  TaskEither<String, Map<AddressV2Type, AddressV2>> deriveAddressT({
    required String path,
    required Seed seed,
    required Network network,
    required Set<AddressV2Type> addressKinds,
  }) {
    return TaskEither.tryCatch(
      () => deriveAddress(
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
      (e_, _) => "error deriving private key",
    );
  }
}
