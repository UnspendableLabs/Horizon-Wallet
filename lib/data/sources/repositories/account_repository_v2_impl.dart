import 'package:get_it/get_it.dart';
import 'package:horizon/extensions.dart';
// import "package:horizon/data/sources/local/dao/accounts_v2_dao.dart";
import "package:horizon/data/sources/local/db.dart" as local;
import "package:horizon/domain/entities/account_v2.dart";
import "package:horizon/domain/repositories/account_v2_repository.dart";
import "package:horizon/domain/repositories/wallet_config_repository.dart";

class AccountV2RepositoryImpl implements AccountV2Repository {
  // ignore: unused_field
  final local.DB _db;
  // final AccountsV2Dao _accountDao;
  final WalletConfigRepository _walletConfigRepository;

  AccountV2RepositoryImpl(this._db)
      :
        // : _accountDao = AccountsV2Dao(_db),
        _walletConfigRepository = GetIt.I<WalletConfigRepository>();

// TODO: make option
  @override
  Future<List<AccountV2>> getByWalletConfig(
      {required String walletConfigID}) async {
    final walletConfig_ =
        await _walletConfigRepository.getByID(id: walletConfigID);

    final walletConfig = walletConfig_.getOrThrow();

    return List.generate(walletConfig.accountIndexEnd + 1, (i) => i)
        .map((i) => AccountV2(
            // uuid: uuid.v4(),
            walletConfigID: walletConfig.uuid,
            index: i))
        .toList();
  }
}
