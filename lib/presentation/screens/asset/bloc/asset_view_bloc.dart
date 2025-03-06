import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/screens/asset/bloc/asset_view_event.dart';
import 'package:horizon/remote_data_bloc/remote_data_state.dart';

class AssetViewBloc
    extends Bloc<AssetViewEvent, RemoteDataState<MultiAddressBalance>> {
  final BalanceRepository balanceRepository;
  final List<String> addresses;
  final String asset;

  AssetViewBloc({
    required this.balanceRepository,
    required this.addresses,
    required this.asset,
  }) : super(const RemoteDataState<MultiAddressBalance>.initial()) {
    on<PageLoaded>(_onPageLoaded);
  }

  Future<void> _onPageLoaded(PageLoaded event, emit) async {
    emit(const RemoteDataState<MultiAddressBalance>.loading());
    // TODO: use new endpoint when ready
    final List<MultiAddressBalance> balances =
        await balanceRepository.getBalancesForAddresses(addresses);

    final balancesByAsset =
        balances.where((balance) => balance.asset == asset).toList();
    if (balancesByAsset.length > 1) {
      emit(RemoteDataState<MultiAddressBalance>.error(
          'Multiple balances found for asset $asset'));
    } else {
      emit(RemoteDataState<MultiAddressBalance>.success(balancesByAsset.first));
    }
  }
}
