// import "package:uniparty/data/sources/local/dao/wallet_dao.dart";
// import "package:uniparty/data/sources/local/db.dart" as local;
// import "package:uniparty/domain/entities/wallet.dart" as entity;
// import "package:uniparty/domain/repositories/wallet_repository.dart";
//
// class WalletRepositoryImpl implements WalletRepository {
//   final local.DB _db;
//   final WalletDao _walletDao;
//
//   WalletRepositoryImpl(this._db) : _walletDao = WalletDao(_db);
//
//   @override
//   Future<void> insert(entity.Wallet wallet) async {
//     _walletDao.insertWallet(
//         local.Wallet(uuid: wallet.uuid, accountUuid: wallet.accountUuid, publicKey: wallet.publicKey, wif: wallet.wif));
//   }
// }
