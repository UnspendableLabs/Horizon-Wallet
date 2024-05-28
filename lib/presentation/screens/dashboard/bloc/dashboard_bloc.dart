import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardState()) {
    final addressRepository = GetIt.I<AddressRepository>();
    final accountRepository = GetIt.I<AccountRepository>();
    final walletRepository = GetIt.I<WalletRepository>();
    on<SetAccountAndWallet>((event, emit) async {
      Account? account = await accountRepository.getCurrentAccount();
      final wallets = await walletRepository.getWalletsByAccountUuid(account!.uuid!);
      emit(state.copyWith(
          accountState: AccountStateSuccess(currentAccount: account),
          walletState: WalletStateSuccess(currentWallet: wallets[0], wallets: wallets)));
    });

    on<GetAddresses>((event, emit) async {
      emit(state.copyWith(addressState: AddressStateLoading()));

      final wallet = state.walletState.currentWallet;

      final addresses = await addressRepository.getAllByWalletUuid(wallet!.uuid!);
      // Get addresses
      emit(state.copyWith(addressState: AddressStateSuccess(currentAddress: addresses[0], addresses: addresses)));
    });

    on<ChangeAddress>((event, emit) {
      emit(state.copyWith(
          addressState: AddressStateSuccess(currentAddress: event.address, addresses: state.addressState.addresses)));
    });
  }
}
