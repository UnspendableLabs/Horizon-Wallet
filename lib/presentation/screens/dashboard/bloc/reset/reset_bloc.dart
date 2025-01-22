import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/reset/reset_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/reset/reset_state.dart';
import 'package:logger/logger.dart';

class ResetBloc extends Bloc<ResetEvent, ResetState> {
  final logger = Logger();

  final WalletRepository walletRepository;
  final AccountRepository accountRepository;
  final AddressRepository addressRepository;
  final ImportedAddressRepository importedAddressRepository;
  final CacheProvider cacheProvider;
  final AnalyticsService analyticsService;

  ResetBloc(
      {required this.walletRepository,
      required this.accountRepository,
      required this.addressRepository,
      required this.importedAddressRepository,
      required this.analyticsService,
      required this.cacheProvider})
      : super(const ResetState()) {
    on<ResetEvent>(_onReset);
  }

  void _onReset(ResetEvent event, Emitter emit) async {
    logger.d('Reset event received');
    await walletRepository.deleteAllWallets();
    await accountRepository.deleteAllAccounts();
    await addressRepository.deleteAllAddresses();
    await importedAddressRepository.deleteAllImportedAddresses();
    cacheProvider.removeAll();

    analyticsService.reset();

    logger.d('emit reset state');
    emit(ResetState(resetState: Out()));
  }
}