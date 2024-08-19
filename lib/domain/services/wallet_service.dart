import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/services/encryption_service.dart';

// TODO: define mnemonic type
abstract class WalletService {
  EncryptionService encryptionService;

  WalletService(this.encryptionService);

  Future<Wallet> deriveRoot(String mnemonic, String password);
  Future<Wallet> deriveRootFreewallet(String mnemonic, String password);

  Future<Wallet> fromPrivateKey(String privateKey, String chainCodeHex);

  Future<Wallet> fromBase58(String privateKey, String password);
}
