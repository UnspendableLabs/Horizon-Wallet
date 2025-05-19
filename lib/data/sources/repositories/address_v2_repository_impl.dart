import "package:fpdart/fpdart.dart";
import 'package:get_it/get_it.dart';
import 'package:horizon/extensions.dart';
// import "package:horizon/data/sources/local/dao/addresss_v2_dao.dart";
import "package:horizon/data/sources/local/db.dart" as local;
import 'package:horizon/domain/services/address_service.dart';
import "package:horizon/domain/entities/decryption_strategy.dart";
import "package:horizon/domain/entities/address_v2.dart";
import "package:horizon/domain/entities/account_v2.dart";
import "package:horizon/domain/repositories/address_v2_repository.dart";
import "package:horizon/domain/repositories/wallet_config_repository.dart";
import "package:horizon/domain/repositories/imported_address_repository.dart";
import 'package:horizon/domain/services/seed_service.dart';
import "package:horizon/js/bitcoin.dart";
import 'package:horizon/domain/services/imported_address_service.dart';

class AddressV2RepositoryImpl implements AddressV2Repository {
  final WalletConfigRepository _walletConfigRepository;
  final AddressService _addressService;
  final SeedService _seedService;
  final ImportedAddressRepository _importedAddressRepository;
  final ImportedAddressService _importedAddressService;

  AddressV2RepositoryImpl(
      {AddressService? addressService,
      WalletConfigRepository? walletConfigRepository,
      SeedService? seedService,
      ImportedAddressRepository? importedAddressRepository,
      ImportedAddressService? importedAddressService})
      : _addressService = addressService ?? GetIt.I<AddressService>(),
        _walletConfigRepository =
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>(),
        _seedService = seedService ?? GetIt.I<SeedService>(),
        _importedAddressRepository =
            importedAddressRepository ?? GetIt.I<ImportedAddressRepository>(),
        _importedAddressService =
            importedAddressService ?? GetIt.I<ImportedAddressService>();

  @override
  Future<List<AddressV2>> getByAccount(AccountV2 account) async {
    const numAddresses = 1;

    TaskEither<String, List<AddressV2>> task = switch (account) {
      Bip32(walletConfigID: var walletConfigID, index: var index) => _walletConfigRepository
          .getByIDT(
              id: walletConfigID,
              onError: (_) => "invariant: could not read wallet config")
          .flatMap((walletConfig) => TaskEither.fromOption(
              walletConfig, () => "invariant: wallet config is null"))
          .flatMap((walletConfig) => _seedService
              .getForWalletConfigT(
                  walletConfig: walletConfig,
                  decryptionStrategy: InMemoryKey(),
                  onError: (_) => "invariant: could not read seed")
              .flatMap((seed) => TaskEither.sequenceList(
                  List.generate(numAddresses, (i) => i)
                      .map((index) => "${walletConfig.basePath.get(walletConfig.network)}${account.index}'/0/$index")
                      .map((path) => _addressService.deriveAddressWIPT(path: path, seed: seed, network: walletConfig.network))
                      .toList()))),
      ImportedWIF(address: var address, encryptedWIF: var encryptedWIF) =>

        TaskEither.right([
          AddressV2(
            type: AddressV2Type.p2wpkh, // TODO: this should not be hard coded
            address: address,
            derivation: WIF(value: encryptedWIF),
            publicKey: "", // TODO: need to add public key
          )
        ])
    };

    final result = await task.run();

    return result.fold(
        (_) => throw Exception(
            "Error deriving addresses for account: ${account.name}"),
        (addresses) {
      return addresses;
    });
  }

  @override
  Future<List<AddressV2>> getAllImported() async {
    final task = TaskEither<String, List<AddressV2>>.Do(($) async {
      final importedAddresses = await $(
        _importedAddressRepository.getAllT(
          onError: (_, __) => "invariant: could not read imported addresses",
        ),
      );

      return [];
    });

    throw UnimplementedError("");
  }
}
