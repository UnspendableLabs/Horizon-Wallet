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
    AccountModel account_ = AccountModel(
      uuid: account.uuid ?? uuid.v4(),
      name: account.name ?? '',
      walletUuid: account.walletUuid!,
      purposeUuid: account.purposeUuid!,
      accountIndex: account.accountIndex!,
      coinUuid: account.coinUuid!,
      xPub: account.xPub!,
    );

    await _accountDao.insertAccount(account_);
  }

  @override
  Future<entity.Account?> getAccountByUuid(String uuid) async {
    AccountModel? account = await _accountDao.getAccountByUuid(uuid);
    return account != null
        ? entity.Account(
            uuid: account.uuid,
            walletUuid: account.walletUuid,
            purposeUuid: account.purposeUuid,
            accountIndex: account.accountIndex,
            name: account.name,
            coinUuid: account.coinUuid,
            xPub: account.xPub)
        : null;
  }

  @override
  Future<List<entity.Account>> getAccountsForWalletPurposeAndCoin(String walletUuid, String purposeUuid, String coinUuid) async {
    List<AccountModel> accounts = await _accountDao.getAccountsForWalletPurposeAndCoin(walletUuid, purposeUuid, coinUuid);
    return accounts
        .map((account) => entity.Account(
            uuid: account.uuid,
            walletUuid: account.walletUuid,
            purposeUuid: account.purposeUuid,
            accountIndex: account.accountIndex,
            name: account.name,
            coinUuid: account.coinUuid,
            xPub: account.xPub))
        .toList();
  }

  @override
  Future<List<entity.Account>> getAccountsByPurposeUuid(String purposeUuid) async {
    List<AccountModel> accounts = await _accountDao.getAccountsByPurposeUuid(purposeUuid);
    return accounts
        .map((account) => entity.Account(
            uuid: account.uuid,
            walletUuid: account.walletUuid,
            purposeUuid: account.purposeUuid,
            accountIndex: account.accountIndex,
            name: account.name,
            coinUuid: account.coinUuid,
            xPub: account.xPub))
        .toList();
  }

  @override
  Future<void> deleteAccount(entity.Account account) async {
    await _accountDao.deleteAccount(AccountModel(
        uuid: account.uuid!,
        walletUuid: account.walletUuid!,
        purposeUuid: account.purposeUuid!,
        accountIndex: account.accountIndex!,
        name: account.name!,
        coinUuid: account.coinUuid!,
        xPub: account.xPub!));
  }

  @override
  Future<void> deleteAllAccounts() async {
    await _accountDao.deleteAllAccounts();
  }
}
