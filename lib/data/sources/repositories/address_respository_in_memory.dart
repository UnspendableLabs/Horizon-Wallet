import "package:horizon/domain/entities/address.dart";
import "package:horizon/domain/repositories/address_repository.dart";
import "package:horizon/domain/repositories/account_repository.dart";
import "package:horizon/domain/repositories/account_v2_repository.dart";
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/repositories/mnemonic_repository.dart';
import 'package:horizon/extensions.dart';

class AddressRepositoryInMemory implements AddressRepository {
  // ignore: unused_field

  AccountV2Repository _accountV2Repository;
  AccountRepository _accountRepository;
  InMemoryKeyRepository _inMemoryKeyRepository;
  WalletRepository _walletRepository;
  AddressService _addressService;
  EncryptionService _encryptionService;
  MnemonicRepository _mnemonicRepository;

  AddressRepositoryInMemory({
    AccountV2Repository? accountV2Repository,
    AccountRepository? accountRepository,
    InMemoryKeyRepository? inMemoryKeyRepository,
    WalletRepository? walletRepository,
    AddressService? addressService,
    EncryptionService? encryptionService,
    MnemonicRepository? mnemonicRepository,
  })  : _accountV2Repository =
            accountV2Repository ?? GetIt.I<AccountV2Repository>(),
        _mnemonicRepository =
            mnemonicRepository ?? GetIt.I<MnemonicRepository>(),
        _inMemoryKeyRepository =
            inMemoryKeyRepository ?? GetIt.I<InMemoryKeyRepository>(),
        _accountRepository = accountRepository ?? GetIt.I<AccountRepository>(),
        _walletRepository = walletRepository ?? GetIt.I<WalletRepository>(),
        _addressService = addressService ?? GetIt.I<AddressService>(),
        _encryptionService = encryptionService ?? GetIt.I<EncryptionService>();

  @override
  Future<void> insert(Address address) async {
    throw UnimplementedError();
  }

  @override
  Future<void> insertMany(List<Address> addresses) async {
    throw UnimplementedError();
  }

  @override
  Future<Address?> getAddress(String address) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Address>> getAllByAccountUuid(String accountUuid) async {
    final account =
        (await _accountV2Repository.getByID(accountUuid)).getOrThrow();

    final encryptedMnemonic = (await _mnemonicRepository.get()).getOrThrow();

    final inMemoryKey = await _inMemoryKeyRepository.getMnemonicKey();

    final mnemonic = await _encryptionService.decryptWithKey(
        encryptedMnemonic, inMemoryKey!);

    // should maybe be a declarative configuration?????

    final paths = [
      "m/84'/0'/${account.index}'/0/0",
      "m/84'/0'/${account.index}'/0/1",
      "m/84'/0'/${account.index}'/0/2",
      "m/84'/0'/${account.index}'/0/3",
      "m/84'/0'/${account.index}'/0/4",
      "m/84'/0'/${account.index}'/0/5",
      "m/84'/0'/${account.index}'/0/6",
      "m/84'/0'/${account.index}'/0/7",
      "m/84'/0'/${account.index}'/0/8",
      "m/84'/0'/${account.index}'/0/9",
    ];

    // for now, we can just reuse Address but i'm not sure we even
    // want to write accounts to the DB, in fact, i think it is more likely that we
    // do NOT want them

    // TODO: network needs to be more of a runtime concept...

    // for each path, all we need to to is generate the address

    List<Address> addresses = [];
    for (final path in paths) {
      print("we are deriving");

      final start = DateTime.now();

      String address_ = await _addressService.deriveAddressWIP(
          path: path, mnemonic: mnemonic);

      final duration = DateTime.now().difference(start);

      print("we are done deriving: ${duration.inMilliseconds} ms");

      Address address = Address(
        address: address_,
        index: 0,
        accountUuid: account.uuid,
      );

      addresses.add(address);
    }

    // final decryptionKey = await _inMemoryKeyRepository.get();
    //
    //
    // final wallet = await walletRepository.getCurrentWallet();
    //
    // final account = (await _accountRepository.getAccountByUuid(accountUuid))!;
    //
    // final privKey = await _encryptionService.decryptWithKey(
    //     wallet!.encryptedPrivKey, decryptionKey!);
    //
    // Address address = await _addressService.deriveAddressSegwit(
    //   privKey: privKey,
    //   chainCodeHex: wallet.chainCodeHex,
    //   accountUuid: account.uuid,
    //   purpose: account.purpose,
    //   coin: account.coinType,
    //   account: account.accountIndex,
    //   change: '0',
    //   index: 0,
    // );
    //
    // return [address];
    return addresses;
  }

  @override
  Future<void> deleteAddresses(String accountUuid) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAllAddresses() async {
    throw UnimplementedError();
  }

  @override
  Future<List<Address>> getAll() async {
    throw UnimplementedError();
  }
}
