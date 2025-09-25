import "./usecase.dart";
export "./usecase.dart";

import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/account_configurations_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/secure_kv_service.dart';
import 'package:get_it/get_it.dart';

final class ResetWalletUseCase implements UseCaseFuture<void, NoParams> {
  final WalletRepositoryDeprecated _walletRepoDeprecated;
  final AccountRepositoryDeprecated _accountRepoDeprecated;
  final AddressRepositoryDeprecated _addressRepoDeprecated;
  final ImportedAddressRepository _importedAddressRepo;
  final TransactionLocalRepository _txLocalRepo;
  final SecureKVService _secureKv;
  final AnalyticsService _analytics;
  final AccountConfigurationsRepository _accountConfigRepo;
  final WalletConfigRepository? _walletConfigRepo;
  final CacheProvider _cacheProvider;

  ResetWalletUseCase({
    WalletRepositoryDeprecated? walletRepoDeprecated,
    AccountRepositoryDeprecated? accountRepoDeprecated,
    AddressRepositoryDeprecated? addressRepoDeprecated,
    ImportedAddressRepository? importedAddressRepo,
    TransactionLocalRepository? txLocalRepo,
    InMemoryKeyRepository? inMemoryKeys,
    SecureKVService? secureKv,
    AnalyticsService? analytics,
    CacheProvider? cacheProvider,
    AccountConfigurationsRepository? accountConfigRepo,
    WalletConfigRepository? walletConfigRepo,
  })  : _analytics = analytics ?? GetIt.I<AnalyticsService>(),
        _secureKv = secureKv ?? GetIt.I<SecureKVService>(),
        _txLocalRepo = txLocalRepo ?? GetIt.I<TransactionLocalRepository>(),
        _importedAddressRepo =
            importedAddressRepo ?? GetIt.I<ImportedAddressRepository>(),
        _addressRepoDeprecated =
            addressRepoDeprecated ?? GetIt.I<AddressRepositoryDeprecated>(),
        _walletRepoDeprecated =
            walletRepoDeprecated ?? GetIt.I<WalletRepositoryDeprecated>(),
        _accountRepoDeprecated =
            accountRepoDeprecated ?? GetIt.I<AccountRepositoryDeprecated>(),
        _cacheProvider = cacheProvider ?? GetIt.I<CacheProvider>(),
        _accountConfigRepo =
            accountConfigRepo ?? GetIt.I<AccountConfigurationsRepository>(),
        _walletConfigRepo =
            walletConfigRepo ?? GetIt.I<WalletConfigRepository>();

  @override
  Future<void> call(NoParams _) async {
    await _walletRepoDeprecated.deleteAllWallets();
    await _accountRepoDeprecated.deleteAllAccounts();
    await _addressRepoDeprecated.deleteAllAddresses();
    await _importedAddressRepo.deleteAllImportedAddresses();
    await _txLocalRepo.deleteAllTransactions();
    await _accountConfigRepo.deleteAll();
    await _secureKv.deleteAll();
    await _cacheProvider.removeAll();
    await _walletConfigRepo?.deleteAll();
    _analytics.reset();
  }
}
