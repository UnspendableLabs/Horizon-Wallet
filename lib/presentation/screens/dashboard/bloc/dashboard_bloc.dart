import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardState()) {
    final walletRepository = GetIt.I<WalletRepository>();
    final accountRepository = GetIt.I<AccountRepository>();
    final addressRepository = GetIt.I<AddressRepository>();

    on<SetAccountAndWallet>((event, emit) async {
      Wallet? wallet = await walletRepository.getCurrentWallet();
      List<Account> accounts = await accountRepository.getAccountsByWalletUuid(wallet!.uuid!);
      emit(state.copyWith(
          walletState: WalletStateSuccess(currentWallet: wallet),
          accountState: AccountStateSuccess(currentAccount: accounts[0], accounts: accounts)));
    });

    on<GetAddresses>((event, emit) async {
      emit(state.copyWith(addressState: AddressStateLoading()));

      final account = state.accountState.currentAccount;

      final addresses = await addressRepository.getAllByAccountUuid(account!.uuid!);
      // Get addresses
      emit(state.copyWith(addressState: AddressStateSuccess(currentAddress: addresses[0], addresses: addresses)));
    });

    on<ChangeAddress>((ChangeAddress event, emit) async {
      emit(state.copyWith(addressState: AddressStateLoading()));

      List<Address> addresses = await addressRepository.getAllByAccountUuid(event.address.accountUuid!);
      emit(state.copyWith(addressState: AddressStateSuccess(currentAddress: event.address, addresses: addresses)));
    });

    on<DeleteWallet>((event, emit) async {
      await addressRepository.deleteAllAddresses();
      await walletRepository.deleteAllWallets();
      await accountRepository.deleteAllAccounts();
    });
  }
}
