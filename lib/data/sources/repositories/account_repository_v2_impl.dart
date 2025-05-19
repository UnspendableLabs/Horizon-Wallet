import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/extensions.dart';
import 'package:horizon/common/constants.dart';
// import "package:horizon/data/sources/local/dao/accounts_v2_dao.dart";
import "package:horizon/data/sources/local/db.dart" as local;
import "package:horizon/domain/entities/account_v2.dart";
import "package:horizon/domain/repositories/account_v2_repository.dart";
import "package:horizon/domain/repositories/wallet_config_repository.dart";
import "package:horizon/domain/repositories/imported_address_repository.dart";
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import "package:horizon/domain/entities/network.dart";
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';

class AccountV2RepositoryImpl implements AccountV2Repository {
  // ignore: unused_field
  final local.DB _db;
  // final AccountsV2Dao _accountDao;
  final WalletConfigRepository _walletConfigRepository;
  final ImportedAddressRepository _importedAddressRepository;
  final ImportedAddressService _importedAddressService;
  final EncryptionService _encryptionService;
  final InMemoryKeyRepository _inMemoryKeyRepository;

  AccountV2RepositoryImpl(this._db)
      : _inMemoryKeyRepository = GetIt.I<InMemoryKeyRepository>(),
        _importedAddressRepository = GetIt.I<ImportedAddressRepository>(),
        // : _accountDao = AccountsV2Dao(_db),
        _walletConfigRepository = GetIt.I<WalletConfigRepository>(),
        _importedAddressService = GetIt.I<ImportedAddressService>(),
        _encryptionService = GetIt.I<EncryptionService>();

  @override
  Future<List<AccountV2>> getByWalletConfig(
      {required String walletConfigID}) async {
    final walletConfig_ =
        await _walletConfigRepository.getByID(id: walletConfigID);

    return [
      ...(await getBip32ByWalletConfig_(walletConfigID: walletConfigID)),
      ...(await getImported_(network: walletConfig_.getOrThrow().network))
    ];
  }

  Future<List<Bip32>> getBip32ByWalletConfig_(
      {required String walletConfigID}) async {
    final task = TaskEither<String, List<Bip32>>.Do(($) async {
      final walletConfig = await $(_walletConfigRepository
          .getByIDT(
              id: walletConfigID,
              onError: (_) => "invariant: could not read wallet config")
          .flatMap((walletConfig) => TaskEither.fromOption(
              walletConfig, () => "invariant: wallet config is null")));

      final bip32Accounts =
          List.generate(walletConfig.accountIndexEnd + 1, (i) => i)
              .map((i) => Bip32(
                  // uuid: uuid.v4(),
                  walletConfigID: walletConfig.uuid,
                  index: i))
              .toList();

      return bip32Accounts;
    });

    final result = await task.run();

    return result.fold(
      (error) => throw Exception(error.toString()),
      (bip32Accounts) => bip32Accounts,
    );
  }

  Future<List<ImportedWIF>> getImported_({required Network network}) async {
    final task = TaskEither<String, List<ImportedWIF>>.Do(($) async {
      final importedAddresses = await $(_importedAddressRepository
          .getAllT(
              onError: (_, __) =>
                  "invariant: could not read imported addresses")
          .map((addresses) =>
              addresses.filter((address) => address.network == network)));

      List<TaskEither<String, ImportedWIF>> tasks = importedAddresses
          .map((address) => _inMemoryKeyRepository
              .getMapT(
                  onError: (_, __) =>
                      "invariant: failed to read in memory key map")
              .flatMap((map) => TaskEither.fromOption(
                  Option.fromNullable(map[address.encryptedWif]),
                  () => "invariant: key not found"))
              .flatMap((key) => _encryptionService.decryptWithKeyT(
                  data: address.encryptedWif,
                  key: key,
                  onError: (_, __) => "invariant: failed to decrypt WIF"))
              .flatMap(
                  (wif) { 

                    print("wif: $wif");
                    print("network: $network");

                    return _importedAddressService.getAddressFromWIFT<String>(
                      wif: wif,
                      // TODO: obviously format needs to be dynamic
                      format: ImportAddressPkFormat.segwit,
                      network: network,
                      onError: (err, __) => "error deriving imported address: $err");})
              .map((String address_) => ImportedWIF(
                    encryptedWIF: address.encryptedWif,
                    network: network,
                    // uuid: uuid.v4(),
                    address: address_,
                  )))
          .toList();

      return await $(TaskEither.sequenceList(tasks));
    });

    final result = await task.run();

    return result.fold(
      (error) => throw Exception(error.toString()),
      (importedAddresses) => importedAddresses,
    );
  }
}
