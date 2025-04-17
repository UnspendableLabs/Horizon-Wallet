import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/secure_kv_service.dart';
import 'package:horizon/presentation/screens/settings/reset_wallet/bloc/reset_event.dart';
import 'package:horizon/presentation/screens/settings/reset_wallet/bloc/reset_state.dart';
import 'package:logger/logger.dart';

class ResetBloc extends Bloc<ResetEvent, ResetState> {
  final logger = Logger();

  final WalletRepository walletRepository;
  final AccountRepository accountRepository;
  final AddressRepository addressRepository;
  final ImportedAddressRepository importedAddressRepository;
  final CacheProvider cacheProvider;
  final TransactionLocalRepository transactionLocalRepository;
  final AnalyticsService analyticsService;
  final InMemoryKeyRepository inMemoryKeyRepository;
  final SecureKVService kvService;

  ResetBloc({
    required this.inMemoryKeyRepository,
    required this.walletRepository,
    required this.accountRepository,
    required this.addressRepository,
    required this.importedAddressRepository,
    required this.transactionLocalRepository,
    required this.analyticsService,
    required this.cacheProvider,
    required this.kvService,
  }) : super(const ResetState()) {
    on<ResetEvent>(_onReset);
  }

  void _onReset(ResetEvent event, Emitter emit) async {
    logger.d('Reset event received');
    await walletRepository.deleteAllWallets();
    await accountRepository.deleteAllAccounts();
    await addressRepository.deleteAllAddresses();
    await importedAddressRepository.deleteAllImportedAddresses();
    await transactionLocalRepository.deleteAllTransactions();
    // logout effects
    await inMemoryKeyRepository.delete();
    await kvService.delete(key: kInactivityDeadlineKey);

    final isDarkMode = cacheProvider.getBool("isDarkMode");

    await cacheProvider.removeAll();

    analyticsService.reset();

    await cacheProvider.setBool("isDarkMode", isDarkMode ?? true);

    logger.d('emit reset state');
    emit(const ResetState(status: ResetStatus.completed));
  }
}
