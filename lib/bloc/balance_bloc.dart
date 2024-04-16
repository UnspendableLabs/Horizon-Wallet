import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/counterparty_api/counterparty_api.dart';

sealed class BalanceState {
  const BalanceState();
}

final class BalanceInitial extends BalanceState {
  const BalanceInitial();
}

final class BalanceLoading extends BalanceState {
  const BalanceLoading();
}

final class BalanceSuccess extends BalanceState {
  final dynamic data;
  const BalanceSuccess({required this.data});
}

final class BalanceError extends BalanceState {
  final String message;
  const BalanceError({required this.message});
}

class LoadBalanceEvent {
  String address;
  NetworkEnum network;
  LoadBalanceEvent({required this.address, required this.network});
}

class BalanceBloc extends Bloc<LoadBalanceEvent, BalanceState> {
  BalanceBloc() : super(const BalanceInitial()) {
    on<LoadBalanceEvent>((event, emit) => _onBalanceLoad(event, emit));
  }
}

_onBalanceLoad(LoadBalanceEvent event, Emitter<BalanceState> emit) async {
  emit(const BalanceLoading());
  final CounterpartyApi counterpartyApi = GetIt.I.get<CounterpartyApi>();
  // final obj = await counterpartyApi.fetchBalance(widget.walletNode.address, widget.network);
  // print('balance $obj');
  // return obj.toString();

  try {
    final balance = await counterpartyApi.fetchBalance(event.address, event.network);
    emit(BalanceSuccess(data: balance));
  } catch (error) {
    emit(BalanceError(message: ''));
  }
  // print('BALANCE? $balance');
}
