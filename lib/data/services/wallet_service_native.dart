import 'package:horizon/domain/entities/wallet.dart' as entity;
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/domain/repositories/config_repository.dart';

class WalletServiceNative implements WalletService {
  final Config config;
  @override
  EncryptionService encryptionService;

  WalletServiceNative(this.encryptionService, this.config);


  @override
  Future<entity.Wallet> deriveRoot(String mnemonic, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<entity.Wallet> deriveRootFreewallet(
      String mnemonic, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<entity.Wallet> deriveRootCounterwallet(
      String mnemonic, String password) async {
    throw UnimplementedError();
  }

  // TODO: this is only used for now to validate password
  // so we can use dummy fields for uuid, name,
  // encryptedPK.  we just want to make sure that
  // the generated public key matched current wallet.
  @override
  Future<entity.Wallet> fromPrivateKey(
      String privateKey, String chainCodeHex) async {
    throw UnimplementedError();
  }

  @override
  Future<entity.Wallet> fromBase58(String privateKey, String password) async {
    throw UnimplementedError();
  }

}

