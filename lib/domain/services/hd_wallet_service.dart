import 'package:horizon/domain/entities/hd_wallet_entity.dart';

abstract class HDWalletService {
  Future<HDWalletEntity> deriveHDWallet({
    required String mnemonic,
    required String password,
    required String purpose,
    required int coinType,
    required int accountIndex,
  });
  Future<HDWalletEntity> deriveFreewalletBech32HDWallet({
    required String mnemonic,
    required String password,
    required String purpose,
    required int coinType,
    required int accountIndex,
  });
  Future<AccountAddressEntity> addNewAccountAndAddress({
    required String encryptedRootWif,
    required String walletUuid,
    required String password,
    required String purpose,
    required int coinType,
    required int accountIndex,
  });
}
