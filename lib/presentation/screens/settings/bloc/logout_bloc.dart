import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/presentation/screens/settings/bloc/logout_event.dart';
import 'package:horizon/presentation/screens/settings/bloc/logout_state.dart';
import 'package:logger/logger.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final logger = Logger();

  final WalletRepository walletRepository;
  final AccountRepository accountRepository;
  final AddressRepository addressRepository;
  final CacheProvider cacheProvider;

  LogoutBloc(
      {required this.walletRepository,
      required this.accountRepository,
      required this.addressRepository,
      required this.cacheProvider})
      : super(const LogoutState()) {
    on<LogoutEvent>(_onLogout);
  }

  void _onLogout(LogoutEvent event, Emitter emit) async {
    logger.d('Logout event received');
    await walletRepository.deleteAllWallets();
    await accountRepository.deleteAllAccounts();
    await addressRepository.deleteAllAddresses();
    cacheProvider.removeAll();

    logger.d('emit logout state');
    emit(LogoutState(logoutState: LoggedOut()));
  }
}
