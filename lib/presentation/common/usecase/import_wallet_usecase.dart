import 'package:horizon/common/constants.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/repositories/config_repository.dart';

class PasswordException implements Exception {
  final String message;
  PasswordException(this.message);
}

class ImportWalletUseCase {
  final AddressRepository addressRepository;
  final AccountRepository accountRepository;
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final Config config;

  ImportWalletUseCase({
    required this.addressRepository,
    required this.accountRepository,
    required this.walletRepository,
    required this.encryptionService,
    required this.addressService,
    required this.config,
  });

  Future<void> call({
    required String password,
    required ImportFormat importFormat,
    required String secret,
    required Future<Wallet> Function(String, String) deriveWallet,
    required Function(String) onError,
    required Function() onSuccess,
  }) async {
    try {
      switch (importFormat) {
        case ImportFormat.horizon:
          await callHorizon(
              secret: secret, password: password, deriveWallet: deriveWallet);
          break;

        case ImportFormat.freewallet:
          Wallet wallet = await deriveWallet(secret, password);
          String decryptedPrivKey;
          try {
            decryptedPrivKey = await encryptionService.decrypt(
                wallet.encryptedPrivKey, password);
          } catch (e) {
            throw PasswordException('invariant:Invalid password');
          }
          // create an account to house
          Account account = Account(
              name: 'ACCOUNT 1',
              walletUuid: wallet.uuid,
              purpose: '32', // unused in Freewallet path
              coinType: _getCoinType(),
              accountIndex: '0\'',
              uuid: uuid.v4(),
              importFormat: ImportFormat.freewallet);

          List<Address> addressesBech32 =
              await addressService.deriveAddressFreewalletRange(
                  type: AddressType.bech32,
                  privKey: decryptedPrivKey,
                  chainCodeHex: wallet.chainCodeHex,
                  accountUuid: account.uuid,
                  account: account.accountIndex,
                  change: '0',
                  start: 0,
                  end: 9);

          List<Address> addressesLegacy =
              await addressService.deriveAddressFreewalletRange(
                  type: AddressType.legacy,
                  privKey: decryptedPrivKey,
                  chainCodeHex: wallet.chainCodeHex,
                  accountUuid: account.uuid,
                  account: account.accountIndex,
                  change: '0',
                  start: 0,
                  end: 9);

          await walletRepository.insert(wallet);
          await accountRepository.insert(account);
          await addressRepository.insertMany(addressesBech32);
          await addressRepository.insertMany(addressesLegacy);

          break;
        case ImportFormat.counterwallet:
          Wallet wallet = await deriveWallet(secret, password);
          String decryptedPrivKey;
          try {
            decryptedPrivKey = await encryptionService.decrypt(
                wallet.encryptedPrivKey, password);
          } catch (e) {
            throw PasswordException('Invalid password');
          }
          // https://github.com/CounterpartyXCP/counterwallet/blob/1de386782818aeecd7c23a3d2132746a2f56e4fc/src/js/util.bitcore.js#L17
          Account account = Account(
              name: 'ACCOUNT 1',
              walletUuid: wallet.uuid,
              purpose: '0\'',
              coinType: _getCoinType(),
              accountIndex: '0\'',
              uuid: uuid.v4(),
              importFormat: ImportFormat.counterwallet);

          List<Address> addressesBech32 =
              await addressService.deriveAddressFreewalletRange(
                  type: AddressType.bech32,
                  privKey: decryptedPrivKey,
                  chainCodeHex: wallet.chainCodeHex,
                  accountUuid: account.uuid,
                  account: account.accountIndex,
                  change: '0',
                  start: 0,
                  end: 9);

          List<Address> addressesLegacy =
              await addressService.deriveAddressFreewalletRange(
                  type: AddressType.legacy,
                  privKey: decryptedPrivKey,
                  chainCodeHex: wallet.chainCodeHex,
                  accountUuid: account.uuid,
                  // purpose: account.purpose,
                  // coin: account.coinType,
                  account: account.accountIndex,
                  change: '0',
                  start: 0,
                  end: 9);

          await walletRepository.insert(wallet);
          await accountRepository.insert(account);
          await addressRepository.insertMany(addressesBech32);
          await addressRepository.insertMany(addressesLegacy);

          break;

        default:
          throw UnimplementedError();
      }
      onSuccess();
      return;
    } catch (e) {
      if (e is PasswordException) {
        onError(e.message);
      } else {
        onError('An unexpected error occurred importing wallet');
      }
    }
  }

  Future<void> callHorizon({
    required String secret,
    required String password,
    required Future<Wallet> Function(String, String) deriveWallet,
  }) async {
    Wallet wallet = await deriveWallet(secret, password);
    String decryptedPrivKey;
    try {
      decryptedPrivKey =
          await encryptionService.decrypt(wallet.encryptedPrivKey, password);
    } catch (e) {
      throw PasswordException('invariant: Invalid password');
    }

    // m/84'/1'/0'/0
    Account account0 = Account(
      name: 'ACCOUNT 1',
      walletUuid: wallet.uuid,
      purpose: '84\'',
      coinType: '${_getCoinType()}\'',
      accountIndex: '0\'',
      uuid: uuid.v4(),
      importFormat: ImportFormat.horizon,
    );

    Address address = await addressService.deriveAddressSegwit(
      privKey: decryptedPrivKey,
      chainCodeHex: wallet.chainCodeHex,
      accountUuid: account0.uuid,
      purpose: account0.purpose,
      coin: account0.coinType,
      account: account0.accountIndex,
      change: '0',
      index: 0,
    );

    await walletRepository.insert(wallet);
    await accountRepository.insert(account0);
    await addressRepository.insert(address);
  }

  String _getCoinType() => switch (config.network) {
        Network.mainnet => "0",
        _ => "1",
      };
}
