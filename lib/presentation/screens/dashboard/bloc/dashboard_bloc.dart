import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/domain/entities/account.dart';
import 'package:uniparty/domain/repositories/account_repository.dart';
import 'package:uniparty/domain/repositories/address_repository.dart';
import 'package:uniparty/domain/repositories/wallet_repository.dart';
import 'package:uniparty/presentation/screens/dashboard/bloc/dashboard_event.dart';
import 'package:uniparty/presentation/screens/dashboard/bloc/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardState()) {
    final addressRepository = GetIt.I<AddressRepository>();
    final accountRepository = GetIt.I<AccountRepository>();
    final walletRepository = GetIt.I<WalletRepository>();
    on<SetAccountAndWallet>((event, emit) async {
      Account? account = await accountRepository.getCurrentAccount();

      emit(state.copyWith(accountState: AccountStateSuccess(currentAccount: account!)));

      final wallet = await walletRepository.getWalletByUuid(account.uuid!);
      emit(state.copyWith(
          accountState: AccountStateSuccess(currentAccount: account), walletState: WalletStateSuccess(wallet: wallet!)));
    });

    on<GetAddresses>((event, emit) async {
      emit(state.copyWith(addressState: AddressStateLoading()));

      final wallet = state.walletState.wallet;

      final addresses = await addressRepository.getAllByWalletUuid(wallet!.uuid!);
      // Get addresses
      emit(state.copyWith(addressState: AddressStateSuccess(addresses: addresses)));
    });
  }
}
