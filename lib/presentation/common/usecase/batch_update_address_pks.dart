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
    final addresses = await addressRepository.getAddressesWithNullPrivateKey();
    if (addresses.isEmpty) return;

    final wallet =
        await walletRepository.getWallet(addresses.first.accountUuid);
    if (wallet == null) {
      logger.warn('BatchUpdateAddressPksUseCase: Wallet not found.');
      return;
    }

    String decryptedRootPrivKey;
    try {
      decryptedRootPrivKey =
          await encryptionService.decrypt(wallet.encryptedPrivKey, password);
    } catch (e) {
      logger.warn('BatchUpdateAddressPksUseCase: Incorrect password.');
      return;
    }

    const batchSize = 1000;
    for (var i = 0; i < addresses.length; i += batchSize) {
      final batch = addresses.skip(i).take(batchSize).toList();
      final addressToEncryptedPrivateKey = <String, String>{};

      await Future.wait(batch.map((address) async {
        final account =
            await accountRepository.getAccountByUuid(address.accountUuid);
        if (account == null) {
          logger.warn('BatchUpdateAddressPksUseCase: Account not found.');
          return;
        }

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

        final encryptedPrivateKey =
            await encryptionService.encrypt(addressPrivKeyWIF, password);

        addressToEncryptedPrivateKey[address.address] = encryptedPrivateKey;
      }).toList());

      await addressRepository
          .updateAddressesEncryptedPrivateKeys(addressToEncryptedPrivateKey);
    }
  }
}
