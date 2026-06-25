import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';

import './get_balance_event.dart';
import './get_balance_state.dart';

/// Read-only BTC balance lookup for the sats-connect `getBalance` RPC.
/// Fetches confirmed + unconfirmed sats for [address] from the Esplora-backed
/// [BitcoinRepository]; no signing or password is involved.
class GetBalanceBloc extends Bloc<GetBalanceEvent, GetBalanceState> {
  final String address;
  final HttpConfig httpConfig;
  final BitcoinRepository _bitcoinRepository;

  GetBalanceBloc({
    required this.address,
    required this.httpConfig,
    BitcoinRepository? bitcoinRepository,
  })  : _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        super(const GetBalanceState()) {
    on<FetchBalance>(_onFetchBalance);
    add(FetchBalance());
  }

  Future<void> _onFetchBalance(
      FetchBalance event, Emitter<GetBalanceState> emit) async {
    emit(state.copyWith(status: GetBalanceStatus.loading, error: null));
    try {
      final info = await _bitcoinRepository.getAddressInfo(
          address: address, httpConfig: httpConfig);
      final confirmed =
          info.chainStats.fundedTxoSum - info.chainStats.spentTxoSum;
      // Net mempool delta (Esplora model). Intentionally signed: an address
      // spending in the mempool funds < spends, so `unconfirmed` is negative
      // and `total` is the spendable balance net of that pending outflow. Do
      // not clamp to 0 — it would make `total` inconsistent with the chain.
      final unconfirmed =
          info.mempoolStats.fundedTxoSum - info.mempoolStats.spentTxoSum;
      emit(state.copyWith(
        status: GetBalanceStatus.success,
        confirmed: confirmed,
        unconfirmed: unconfirmed,
        total: confirmed + unconfirmed,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GetBalanceStatus.failure,
        error: e.toString(),
      ));
    }
  }
}
