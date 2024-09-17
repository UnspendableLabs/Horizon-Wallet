import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/services/encryption_service.dart';

abstract class WalletService {
  EncryptionService encryptionService;

  WalletService(this.encryptionService);

  Future<Wallet> deriveRoot(String mnemonic, String password);
  Future<Wallet> deriveRootFreewallet(String mnemonic, String password);
  Future<Wallet> deriveRootCounterwallet(String mnemonic, String password);

  Future<Wallet> fromPrivateKey(String privateKey, String chainCodeHex);

  Future<Wallet> fromBase58(String privateKey, String password);
}
