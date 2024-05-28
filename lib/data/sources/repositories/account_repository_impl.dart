import 'package:horizon/common/uuid.dart';
import "package:horizon/data/models/account.dart";
import "package:horizon/data/sources/local/dao/accounts_dao.dart";
import "package:horizon/data/sources/local/db.dart" as local;
import "package:horizon/domain/entities/account.dart" as entity;
import "package:horizon/domain/repositories/account_repository.dart";

class AccountRepositoryImpl implements AccountRepository {
  final local.DB _db;
  final AccountsDao _accountDao;

  AccountRepositoryImpl(this._db) : _accountDao = AccountsDao(_db);

  @override
  Future<void> insert(entity.Account account) async {
    await _accountDao.insertAccount(AccountModel(uuid: account.uuid ?? uuid.v4()));
  }

  @override
  Future<entity.Account?> getAccount(String uuid) async {
    AccountModel? accountLocal = await _accountDao.getAccountByUuid(uuid);
    if (accountLocal == null) {
      return null;
    }
    print('accountLocal: $accountLocal');
    return entity.Account(
      uuid: accountLocal.uuid,
    );
  }

  @override
  Future<entity.Account?> getCurrentAccount() async {
    // TODO: how to mark current account?
    AccountModel? account = await _accountDao.getCurrentAccount();
    return entity.Account(
      uuid: account?.uuid,
    );
    // return null;
  }

  // @override
  // Future<void> initializeWithWalletAndAddresses(
  //     Wallet wallet, List<Address> addresses) async {
  //
  //     await transaction(() async {
  //
  //
  //         await _accountDao.insertAccount(AccountModel(uuid: uuid.v4()));
  //
  //
  //     });
  //
  //
  //
  //
  //
  //
  //   }
}
