import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:horizon/domain/entities/account_v2.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/repositories/address_v2_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';

abstract class AccountBalancesEvent {}

class LoadAccountBalances extends AccountBalancesEvent {
  final List<AccountV2> accounts;
  final HttpConfig httpConfig;
  
  LoadAccountBalances({required this.accounts, required this.httpConfig});
}

 class AccountBalancesState {
  final Map<String, MultiAddressBalance> accountBalances;
  final Map<String, List<AddressV2>> accountAddresses;
  final bool isLoading;
  final fp.Option<String> error;

  AccountBalancesState({
    required this.accountBalances,
    required this.accountAddresses,
    this.isLoading = false,
    this.error = const fp.None(),
  });

  AccountBalancesState copyWith({
    Map<String, MultiAddressBalance>? accountBalances,
    Map<String, List<AddressV2>>? accountAddresses,
    bool? isLoading,
    fp.Option<String>? error,
  }) {
    return AccountBalancesState(
      accountBalances: accountBalances ?? this.accountBalances,
      accountAddresses: accountAddresses ?? this.accountAddresses,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
 }

// Bloc
class AccountBalancesBloc extends Bloc<AccountBalancesEvent, AccountBalancesState> {
  final AddressV2Repository _addressV2Repository;
  final BalanceRepository _balanceRepository;
  
  AccountBalancesBloc({
    required AddressV2Repository addressV2Repository,
    required BalanceRepository balanceRepository,
  }) : _addressV2Repository = addressV2Repository,
       _balanceRepository = balanceRepository,
       super(AccountBalancesState(
        accountBalances: {},
        accountAddresses: {},
        isLoading: false,
        error: const fp.None(),
       )) {
    
    on<LoadAccountBalances>(_onLoadAccountBalances);
  }
  
  Future<void> _onLoadAccountBalances(
    LoadAccountBalances event,
    Emitter<AccountBalancesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      final Map<String, MultiAddressBalance> accountBalances = {};
      final Map<String, List<AddressV2>> accountAddresses = {};
      
      for (final account in event.accounts) {
        final addresses = await _addressV2Repository.getByAccount(account);
        accountAddresses[account.hash] = addresses;
        
        if (addresses.isNotEmpty) {
          final addressStrings = addresses.map((addr) => addr.address).toList();
          final balances = await _balanceRepository.getBalancesForAddresses(
            addresses: addressStrings,
            httpConfig: event.httpConfig,
          );
          
          final btcBalance = balances.firstWhereOrNull(
            (balance) => balance.asset == 'BTC',
          );
          
          if (btcBalance != null) {
            accountBalances[account.hash] = btcBalance;
          }
        }
      }
      
      emit(state.copyWith(
        accountBalances: accountBalances,
        accountAddresses: accountAddresses,
        isLoading: false,
        error: const fp.None(),
      ));
      
    } catch (error) {
      emit(state.copyWith(
        isLoading: false,
        error: fp.Some(error.toString()),
      ));
    }
  }

} 