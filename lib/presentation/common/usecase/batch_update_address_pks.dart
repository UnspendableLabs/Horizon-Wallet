import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';

class BatchUpdateAddressPksUseCase {
  final AddressRepository addressRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final WalletRepository walletRepository;
  final AccountRepository accountRepository;
  final Logger logger;

  BatchUpdateAddressPksUseCase({
    required this.addressRepository,
    required this.encryptionService,
    required this.addressService,
    required this.walletRepository,
    required this.accountRepository,
    required this.logger,
  });

  Future<void> populateEncryptedPrivateKeys(String password) async {
    print('populateEncryptedPrivateKeys');
    final addresses = await addressRepository.getAddressesWithNullPrivateKey();
    print('addresses: ${addresses.length}');
    if (addresses.isEmpty) return;

    // print('addresses.first.accountUuid: ${addresses.first.accountUuid}');
    print('before wallet $password');
    final wallet = await walletRepository.getCurrentWallet();
    print('after wallet $wallet');
    if (wallet == null) {
      logger.warn('BatchUpdateAddressPksUseCase: Wallet not found.');
      return;
    }

    print('before encryptionService');
    String decryptedRootPrivKey;
    try {
      print('before decrypt');
      decryptedRootPrivKey =
          await encryptionService.decrypt(wallet.encryptedPrivKey, password);
      print('after decrypt');
    } catch (e) {
      logger.warn('BatchUpdateAddressPksUseCase: Incorrect password.');
      return;
    }
    print('after decrypt $decryptedRootPrivKey');

    const batchSize = 1000;
    print('before for loop');
    for (var i = 0; i < addresses.length; i += batchSize) {
      print('in for loop $i');
      final batch = addresses.skip(i).take(batchSize).toList();
      final addressToEncryptedPrivateKey = <String, String>{};
      print('BATCH SIZE: $batch');

      await Future.wait(batch.map((address) async {
        final account =
            await accountRepository.getAccountByUuid(address.accountUuid);
        print('account: $account');
        if (account == null) {
          logger.warn('BatchUpdateAddressPksUseCase: Account not found.');
          return;
        }

        print('address: ${address.address}');
        print('account: $account');

        final addressPrivKeyWIF = await addressService.deriveAddressWIF(
          rootPrivKey: decryptedRootPrivKey,
          chainCodeHex: wallet.chainCodeHex,
          purpose: account.purpose,
          coin: account.coinType,
          account: account.accountIndex,
          change: '0',
          index: address.index,
          importFormat: account.importFormat,
        );
        print('addressPrivKeyWIF: $addressPrivKeyWIF');

        final encryptedPrivateKey =
            await encryptionService.encrypt(addressPrivKeyWIF, password);
        print('encryptedPrivateKey: $encryptedPrivateKey');
        addressToEncryptedPrivateKey[address.address] = encryptedPrivateKey;
      }).toList());
      print('addressToEncryptedPrivateKey: $addressToEncryptedPrivateKey');

      await addressRepository
          .updateAddressesEncryptedPrivateKeys(addressToEncryptedPrivateKey);
      print('after updateAddressesEncryptedPrivateKeys');
    }
  }
}
