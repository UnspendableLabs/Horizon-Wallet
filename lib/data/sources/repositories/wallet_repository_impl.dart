import "package:horizon/data/models/wallet.dart";
import "package:horizon/data/sources/local/dao/wallets_dao.dart";
import "package:horizon/data/sources/local/db.dart" as local;
import "package:horizon/domain/entities/wallet.dart" as entity;
import "package:horizon/domain/repositories/wallet_repository.dart";

class WalletRepositoryImpl implements WalletRepositoryDeprecated {
  // ignore: unused_field
  final local.DB _db;
  final WalletsDao _walletDao;

  WalletRepositoryImpl(this._db) : _walletDao = WalletsDao(_db);

  @override
  Future<void> insert(entity.Wallet wallet) async {
    await _walletDao.insertWallet(WalletModel(
        uuid: wallet.uuid,
        name: wallet.name,
        encryptedPrivKey: wallet.encryptedPrivKey,
        encryptedMnemonic: wallet.encryptedMnemonic,
        publicKey: wallet.publicKey,
        chainCodeHex: wallet.chainCodeHex));
  }

  @override
  Future<entity.Wallet?> getWallet(String uuid) async {
    WalletModel? walletLocal = await _walletDao.getWalletByUuid(uuid);
    if (walletLocal == null) {
      return null;
    }
    return entity.Wallet(
        uuid: walletLocal.uuid,
        name: walletLocal.name,
        encryptedPrivKey: walletLocal.encryptedPrivKey,
        encryptedMnemonic: walletLocal.encryptedMnemonic,
        publicKey: walletLocal.publicKey,
        chainCodeHex: walletLocal.chainCodeHex);
  }

  @override
  Future<entity.Wallet?> getCurrentWallet() async {
    WalletModel? wallet = await _walletDao.getCurrentWallet();

    if (wallet == null) {
      return null;
    }

    return entity.Wallet(
        uuid: wallet.uuid,
        name: wallet.name,
        encryptedPrivKey: wallet.encryptedPrivKey,
        encryptedMnemonic: wallet.encryptedMnemonic,
        publicKey: wallet.publicKey,
        chainCodeHex: wallet.chainCodeHex);
  }

  @override
  Future<void> deleteWallet(entity.Wallet wallet) async {
    await _walletDao.deleteWallet(WalletModel(
        uuid: wallet.uuid,
        name: wallet.name,
        encryptedPrivKey: wallet.encryptedPrivKey,
        encryptedMnemonic: wallet.encryptedMnemonic,
        publicKey: wallet.publicKey,
        chainCodeHex: wallet.chainCodeHex));
  }

  @override
  Future<void> deleteAllWallets() async {
    await _walletDao.deleteAllWallets();
  }
}
