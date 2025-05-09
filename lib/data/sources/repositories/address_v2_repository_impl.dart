import 'package:get_it/get_it.dart';
import 'package:horizon/extensions.dart';
// import "package:horizon/data/sources/local/dao/addresss_v2_dao.dart";
import "package:horizon/data/sources/local/db.dart" as local;
import 'package:horizon/domain/services/address_service.dart';
import "package:horizon/domain/entities/address_v2.dart";
import "package:horizon/domain/entities/account_v2.dart";
import "package:horizon/domain/repositories/address_v2_repository.dart";
import "package:horizon/domain/repositories/wallet_config_repository.dart";
import "package:fpdart/fpdart.dart";
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/seed_service.dart';
import 'package:horizon/domain/repositories/mnemonic_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';

class AddressV2RepositoryImpl implements AddressV2Repository {
  // ignore: unused_field
  final local.DB _db;
  // final AddresssV2Dao _addressDao;
  final WalletConfigRepository _walletConfigRepository;
  AddressService _addressService;
  MnemonicRepository _mnemonicRepository;
  EncryptionService _encryptionService;
  InMemoryKeyRepository _inMemoryKeyRepository;
  SeedService _seedService;

  // TODO: shuold be able to inject deps here?
  AddressV2RepositoryImpl(this._db)
      : _addressService = GetIt.I<AddressService>(),
        _encryptionService = GetIt.I<EncryptionService>(),
        _mnemonicRepository = GetIt.I<MnemonicRepository>(),
        _walletConfigRepository = GetIt.I<WalletConfigRepository>(),
        _seedService = GetIt.I<SeedService>(),
        _inMemoryKeyRepository = GetIt.I<InMemoryKeyRepository>();

// TODO: make option
// TODO: this whole thing is a little busy
  @override
  Future<List<AddressV2>> getByAccount(AccountV2 account) async {
    final walletConfig_ =
        await _walletConfigRepository.getByID(id: account.walletConfigID);

    final walletConfig = walletConfig_.getOrThrow();

    final seed = await _seedService
        .getForWalletConfig(walletConfig: walletConfig_.getOrThrow())
        .run();

    // # TODO: need to make the number of addresses configurable and stored
    final numAddresses = 1;

    final paths = List.generate(numAddresses, (i) => i)
        .map((index) => (
              index,
              "${walletConfig.basePath.get(walletConfig.network)}${account.index}'/0/$index"
            ))
        .toList();

    print(paths);

    print(walletConfig);

    List<AddressV2> addresses = [];
    for (final path in paths) {
      String address_ = await _addressService.deriveAddressWIP(
        path: path.$2,
        seed: seed.getRight().getOrThrow(),
        network: walletConfig.network,
      );

      AddressV2 address = AddressV2(
        address: address_,
        index: path.$1,
      );

      addresses.add(address);
    }

    return addresses;
  }
}
