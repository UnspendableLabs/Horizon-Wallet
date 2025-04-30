import "package:horizon/domain/entities/address.dart";
import "package:horizon/domain/repositories/address_repository.dart";
import "package:horizon/domain/repositories/account_repository.dart";
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';

class AddressRepositoryInMemory implements AddressRepository {
  // ignore: unused_field

  AccountRepository accountRepository;
  InMemoryKeyRepository inMemoryKeyRepository;
  WalletRepository walletRepository;
  AddressService addressService;
  EncryptionService encryptionService;

  AddressRepositoryInMemory({
    AccountRepository? accountRepository,
    InMemoryKeyRepository? inMemoryKeyRepository,
    WalletRepository? walletRepository,
    AddressService? addressService,
    EncryptionService? encryptionService,
  })  : inMemoryKeyRepository =
            inMemoryKeyRepository ?? GetIt.I<InMemoryKeyRepository>(),
        accountRepository = accountRepository ?? GetIt.I<AccountRepository>(),
        walletRepository = walletRepository ?? GetIt.I<WalletRepository>(),
        addressService = addressService ?? GetIt.I<AddressService>(),
        encryptionService = encryptionService ?? GetIt.I<EncryptionService>();

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
    final decryptionKey = await inMemoryKeyRepository.get();

    final wallet = await walletRepository.getCurrentWallet();

    final account = (await accountRepository.getAccountByUuid(accountUuid))!;

    final privKey = await encryptionService.decryptWithKey(
        wallet!.encryptedPrivKey, decryptionKey!);

    Address address = await addressService.deriveAddressSegwit(
      privKey: privKey,
      chainCodeHex: wallet.chainCodeHex,
      accountUuid: account.uuid,
      purpose: account.purpose,
      coin: account.coinType,
      account: account.accountIndex,
      change: '0',
      index: 0,
    );

    return [address];
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
