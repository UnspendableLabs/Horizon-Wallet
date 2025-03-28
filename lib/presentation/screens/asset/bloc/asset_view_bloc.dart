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
    final MultiAddressBalance balances = await balanceRepository
        .getBalancesForAddressesAndAsset(addresses, asset);

    emit(RemoteDataState<MultiAddressBalance>.success(balances));
  }
}
