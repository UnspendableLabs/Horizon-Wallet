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
    const batchSize = 10;

    final addresses = await addressRepository.getAddressesWithNullPrivateKey();
    if (addresses.isEmpty) return;

    final wallet = await walletRepository.getCurrentWallet();
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

    final addressBatch = addresses.take(batchSize).toList();

    await Future.wait(addressBatch.map((address) async {
      final account =
          await accountRepository.getAccountByUuid(address.accountUuid);
      if (account == null) {
        logger.warn('BatchUpdateAddressPksUseCase: Account not found.');
        return;
      }

      final addressPrivKeyWIF =
          await addressService.getAddressWIFFromPrivateKey(
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

      await addressRepository.updateAddressEncryptedPrivateKey(
          address.address, encryptedPrivateKey);
    }).toList());
  }
}
