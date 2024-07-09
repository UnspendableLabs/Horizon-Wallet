import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/address_tx_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';

class BalancesBloc extends Bloc<BalancesEvent, BalancesState> {
  final BalanceRepository balanceRepository = GetIt.I.get<BalanceRepository>();
  final AccountRepository accountRepository = GetIt.I.get<AccountRepository>();
  final AddressRepository addressRepository = GetIt.I.get<AddressRepository>();
  final AddressTxRepository addressTxRepository =
      GetIt.I.get<AddressTxRepository>();

  BalancesBloc() : super(const BalancesState.initial()) {
    on<FetchBalances>((event, emit) async {
      emit(const BalancesState.loading());

      final List<Address> addresses =
          await addressRepository.getAllByAccountUuid(event.accountUuid);
      final List<AddressInfo> addressInfo = [];

      for (final address in addresses) {
        final balance = await balanceRepository.getBalance(address.address);
        final transactions =
            await addressTxRepository.getTransactionsByAddress(address.address);
        addressInfo.add(AddressInfo(
            address: address, balances: balance, transactions: transactions));
      }

      emit(BalancesState.success(
          addressInfo: addressInfo, currentAddressBalances: addressInfo.first));

      try {} catch (error) {
        emit(BalancesState.error(error.toString()));
      }
    });
  }
}
