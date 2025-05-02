import 'package:get_it/get_it.dart';
import 'package:horizon/common/uuid.dart';
import "package:horizon/data/sources/local/dao/accounts_v2_dao.dart";
import "package:horizon/data/sources/local/db.dart" as local;
import "package:horizon/domain/entities/account_v2.dart";
import "package:horizon/domain/repositories/account_v2_repository.dart";
import "package:horizon/domain/repositories/wallet_config_repository.dart";
import "package:fpdart/fpdart.dart";

class AccountV2RepositoryImpl implements AccountV2Repository {
  // ignore: unused_field
  final local.DB _db;
  final AccountsV2Dao _accountDao;
  final WalletConfigRepository _walletConfigRepository;

  AccountV2RepositoryImpl(this._db)
      : _accountDao = AccountsV2Dao(_db),
        _walletConfigRepository = GetIt.I<WalletConfigRepository>();

  @override
  Future<Option<AccountV2>> getByID(String id) async {
    final walletConfigs = await _walletConfigRepository.getAll();
    final mainnetConfig = walletConfigs.first;
    return Option.of(AccountV2(
      uuid: uuid.v4(),
      index: mainnetConfig.accountIndexStart,
    ));

    // return Option.fromNullable(await _accountDao.getByUuid(id))
    //     .map((account) => AccountV2(uuid: account.uuid, index: account.index));
  }

  @override
  Future<List<AccountV2>> getAll() async {
    final walletConfigs = await _walletConfigRepository.getAll();
    final mainnetConfig = walletConfigs.first;
    return List.generate(mainnetConfig.accountIndexEnd + 1, (i) => i)
        .map((i) => AccountV2(uuid: uuid.v4(), index: i))
        .toList();
  }

  @override
  Future<void> insert(AccountV2 account) async {
    throw UnimplementedError("no op");
  }

  @override
  Future<void> deleteAll() async {
    throw UnimplementedError("no op");
  }
}
