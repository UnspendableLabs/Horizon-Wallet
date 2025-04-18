// data/services/wallet_service_stub.dart

import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/entities/wallet.dart';

class WalletServiceStub extends WalletService {
  Never _unsupported(String fn) =>
      throw UnimplementedError('$fn is not supported on this platform.');

  @override
  Future<Wallet> deriveRoot(String mnemonic, String password) =>
      Future.error(_unsupported('deriveRoot'));

  @override
  Future<Wallet> deriveRootFreewallet(String mnemonic, String password) =>
      Future.error(_unsupported('deriveRootFreewallet'));

  @override
  Future<Wallet> deriveRootCounterwallet(String mnemonic, String password) =>
      Future.error(_unsupported('deriveRootCounterwallet'));

  @override
  Future<Wallet> fromPrivateKey(String privateKey, String chainCodeHex) =>
      Future.error(_unsupported('fromPrivateKey'));

  @override
  Future<Wallet> fromBase58(String privateKey, String password) =>
      Future.error(_unsupported('fromBase58'));
}

WalletService createWalletServiceImpl({
  required EncryptionService encryptionService,
  required Config config,
}) =>
    WalletServiceStub();
