import "package:fpdart/fpdart.dart";
import 'package:get_it/get_it.dart';
// import "package:horizon/data/sources/local/dao/addresss_v2_dao.dart";
import 'package:horizon/domain/services/address_service.dart';
import "package:horizon/domain/entities/decryption_strategy.dart";
import "package:horizon/domain/entities/address_v2.dart";
import "package:horizon/domain/entities/account_v2.dart";
import "package:horizon/domain/repositories/address_v2_repository.dart";
import "package:horizon/domain/repositories/wallet_config_repository.dart";
import "package:horizon/domain/repositories/imported_address_repository.dart";
import "package:horizon/domain/repositories/account_configurations_repository.dart";
import 'package:horizon/domain/services/seed_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import "package:horizon/domain/entities/address_index_set.dart";
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';

bool addressIsSegwit(String address) {
  return address.startsWith('bc1') || address.startsWith('tb1');
}

class AddressV2RepositoryImpl implements AddressV2Repository {
  final WalletConfigRepository _walletConfigRepository;
  final AddressService _addressService;
  final SeedService _seedService;
  final ImportedAddressRepository _importedAddressRepository;
  final ImportedAddressService _importedAddressService;
  final AccountConfigurationsRepository _accountConfigurationsRepository;
  final InMemoryKeyRepository _inMemoryKeyRepository;
  final EncryptionService _encryptionService;

  AddressV2RepositoryImpl(
      {AddressService? addressService,
      WalletConfigRepository? walletConfigRepository,
      SeedService? seedService,
      ImportedAddressRepository? importedAddressRepository,
      ImportedAddressService? importedAddressService,
      InMemoryKeyRepository? inMemoryKeyRepository,
      EncryptionService? encryptionService,
      AccountConfigurationsRepository? accountConfigurationsRepository})
      : _accountConfigurationsRepository = accountConfigurationsRepository ??
            GetIt.I<AccountConfigurationsRepository>(),
        _addressService = addressService ?? GetIt.I<AddressService>(),
        _walletConfigRepository =
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>(),
        _seedService = seedService ?? GetIt.I<SeedService>(),
        _importedAddressRepository =
            importedAddressRepository ?? GetIt.I<ImportedAddressRepository>(),
        _importedAddressService =
            importedAddressService ?? GetIt.I<ImportedAddressService>(),
        _inMemoryKeyRepository =
            inMemoryKeyRepository ?? GetIt.I<InMemoryKeyRepository>(),
        _encryptionService = encryptionService ?? GetIt.I<EncryptionService>();

  @override
  Future<AddressIndexSet> getByAccountAtIndex(
      Bip32 account, Bip32AddressIndex index) async {
    TaskEither<String, List<AddressV2>> task = _walletConfigRepository
        .getByIDT(
            id: account.walletConfigID,
            onError: (_) => "invariant: could not read wallet config")
        .flatMap((walletConfig) => TaskEither.fromOption(
            walletConfig, () => "invariant: wallet config is null"))
        .flatMap((walletConfig) => _seedService
            .getForWalletConfigT(
                walletConfig: walletConfig,
                decryptionStrategy: InMemoryKey(),
                onError: (_) => "invariant: could not read seed")
            .flatMap((seed) => _addressService.deriveAddressT(
                addressKinds: walletConfig.supportedKinds,
                path:
                    "${walletConfig.basePath.get(walletConfig.network)}${account.index}'/0/${index.value}",
                seed: seed,
                network: walletConfig.network))
            .map((map) => map.values.toList()));

    final result = await task.run();
    return result.fold(
        (err) => throw Exception(
            "$err: Error deriving addresses for account: ${account.name}"),
        (addresses) {
      final map =
          addresses.asMap().map((key, value) => MapEntry(value.type, value));

      return AddressIndexSet(map);
    });
  }

  @override
  Future<AddressIndexSet> getByAccount(AccountV2 account) async {
    TaskEither<String, List<AddressV2>> task = switch (account) {
      Bip32(walletConfigID: var walletConfigID, index: var index) =>
        TaskEither<String, List<AddressV2>>.Do(($) async {
          final walletConfig = await $(_walletConfigRepository
              .getByIDT(
                  id: walletConfigID,
                  onError: (_) => "invariant: could not read wallet config")
              .flatMap((walletConfig) => TaskEither.fromOption(
                  walletConfig, () => "invariant: wallet config is null")));

          final seed = await $(_seedService.getForWalletConfigT(
              walletConfig: walletConfig,
              decryptionStrategy: InMemoryKey(),
              onError: (_) => "invariant: could not read seed"));

          final accountConfig =
              await $(_accountConfigurationsRepository.getByPrimaryKeyT<String>(
            walletId: walletConfig.uuid,
            accountIndex: index,
            onError: (_, __) => "invariant: never",
          ));

          // if there is no explicit config, use the 0th index
          final addressIndex =
              accountConfig.fold(() => 0, (config) => config.addressIndex);

          final addresses = await $(_addressService
              .deriveAddressT(
                  addressKinds: walletConfig.supportedKinds,
                  path:
                      "${walletConfig.basePath.get(walletConfig.network)}$index'/0/$addressIndex",
                  seed: seed,
                  network: walletConfig.network)
              .map((map) => map.values.toList()));

          return addresses;
        }),
      ImportedWIF(address: var address, encryptedWIF: var encryptedWIF) =>
        TaskEither.right([
          AddressV2(
            type: addressIsSegwit(address)
                ? AddressV2Type.p2wpkh
                : AddressV2Type.p2pkh,
            address: address,
            derivation: WIF(value: encryptedWIF),
            publicKey: "", // TODO: need to add public key
          )
        ])
    };

    final result = await task.run();
    return result.fold(
        (err) => throw Exception(
            "$err: Error deriving addresses for account: ${account.name}"),
        (addresses) {
      final map = addresses
          .toList()
          .asMap()
          .map((key, value) => MapEntry(value.type, value));

      return AddressIndexSet(map);
    });
  }

  // TODO: what is the deal with ths
  @override
  Future<List<AddressV2>> getAllImported() async {
    final TaskEither<String, List<AddressV2>> task = _importedAddressRepository
        .getAllT(
          onError: (_, __) => "invariant: could not read imported addresses",
        )
        .flatMap((importedAddresses) => _inMemoryKeyRepository
                .getMapT(
              onError: (_, __) => "invariant: failed to read in memory key map",
            )
                .map((repo) {
              return repo;
            }).flatMap((keyMap) => TaskEither.sequenceList(importedAddresses
                    .map((addy) => TaskEither.fromOption(
                          Option.fromNullable(keyMap[addy.encryptedWif]),
                          () =>
                              "invariant: decryption key not found for address: ${addy.address}",
                        ).flatMap((decryptionKey) => _encryptionService
                            .decryptWithKeyT(
                              data: addy.encryptedWif,
                              key: decryptionKey,
                              onError: (_, __) =>
                                  "failed to decrypt wif for address: ${addy.address}",
                            )
                            .flatMap((wif) => _importedAddressService
                                .getAddressPublicKeyFromWIFT(
                                    wif: wif,
                                    network: addy.network,
                                    onError: (_, __) =>
                                        "failed to get public key for address: ${addy.address}"))
                            .map((publicKey) => AddressV2(
                                publicKey: publicKey,
                                address: addy.address,
                                derivation: WIF(value: addy.encryptedWif),
                                type: addy.type))))
                    .toList())));

    final result = await task.run();

    return result.fold(
        (error) => throw Exception(error), (addresses) => addresses);
  }
}
