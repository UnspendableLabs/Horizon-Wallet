import 'package:horizon/domain/entities/wallet.dart';

abstract class WalletService {


  Future<Wallet> deriveRoot(String mnemonic, String password);
  Future<Wallet> deriveRootFreewallet(String mnemonic, String password);
  Future<Wallet> deriveRootCounterwallet(String mnemonic, String password);

  Future<Wallet> fromPrivateKey(String privateKey, String chainCodeHex);

  Future<Wallet> fromBase58(String privateKey, String password);
}
