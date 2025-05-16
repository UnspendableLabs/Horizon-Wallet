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
import 'package:horizon/domain/services/seed_service.dart';
import "package:horizon/js/bitcoin.dart";

class AddressV2RepositoryImpl implements AddressV2Repository {
  // ignore: unused_field
  final local.DB _db;
  // final AddresssV2Dao _addressDao;
  final WalletConfigRepository _walletConfigRepository;
  final AddressService _addressService;
  final SeedService _seedService;

  // TODO: shuold be able to inject deps here?
  AddressV2RepositoryImpl(this._db)
      : _addressService = GetIt.I<AddressService>(),
        _walletConfigRepository = GetIt.I<WalletConfigRepository>(),
        _seedService = GetIt.I<SeedService>();

// TODO: make optioj
// TODO: this whole thing is a little busy
  @override
  Future<List<AddressV2>> getByAccount(AccountV2 account) async {
    const numAddresses = 1;

    print(account);

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
        print(addresses);
        return addresses;
      }
    );
  }
}
