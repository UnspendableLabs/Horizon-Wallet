import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/fairminter.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/fairminter_repository.dart';
import 'package:horizon/presentation/screens/asset/bloc/asset_view_event.dart';
import 'package:horizon/presentation/screens/compose_fairmint/usecase/fetch_form_data.dart';
import 'package:horizon/remote_data_bloc/remote_data_state.dart';
import 'package:horizon/domain/entities/http_clients.dart';

class AssetViewData {
  final MultiAddressBalance balances;
  final List<Fairminter> fairminters;

  AssetViewData({required this.balances, required this.fairminters});
}

class AssetViewBloc
    extends Bloc<AssetViewEvent, RemoteDataState<AssetViewData>> {
  final HttpClients httpClients;
  final BalanceRepository balanceRepository;
  final FairminterRepository fairminterRepository;
  final List<String> addresses;
  final String asset;

  AssetViewBloc({
    required this.httpClients,
    required this.balanceRepository,
    required this.fairminterRepository,
    required this.addresses,
    required this.asset,
  }) : super(const RemoteDataState<AssetViewData>.initial()) {
    on<PageLoaded>(_onPageLoaded);
  }

  Future<void> _onPageLoaded(PageLoaded event, emit) async {
    emit(const RemoteDataState<AssetViewData>.loading());
    final results = await Future.wait([
      balanceRepository.getBalancesForAddressesAndAsset(
        client: httpClients.counterparty,
        addresses: addresses,
        assetName: asset,
      ),
      fairminterRepository
          .getFairmintersByAsset(asset, 'open')
          .run()
          .then((either) => either.fold(
                (error) => throw FetchFairmintersException(error.toString()),
                (fairminters) => fairminters,
              )),
    ]);

    final MultiAddressBalance balances = results[0] as MultiAddressBalance;
    final List<Fairminter> fairminters = results[1] as List<Fairminter>;

    emit(RemoteDataState<AssetViewData>.success(
        AssetViewData(balances: balances, fairminters: fairminters)));
  }
}
