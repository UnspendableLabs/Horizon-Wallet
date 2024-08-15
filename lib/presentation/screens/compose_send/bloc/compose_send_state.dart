import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_send.dart';

part 'compose_send_state.freezed.dart';

@freezed
class ComposeSendState with _$ComposeSendState {
  const factory ComposeSendState({
    @Default(AddressesState.initial()) addressesState,
    @Default(BalancesState.initial()) balancesState,
    @Default(SubmitState.initial()) submitState,
  }) = _ComposeSendState;
}

@freezed
class BalancesState with _$BalancesState {
  const factory BalancesState.initial() = _BalanceInital;
  const factory BalancesState.loading() = _BalanceLoading;
  const factory BalancesState.success(List<Balance> balances) = _BalanceSuccess;
  const factory BalancesState.error(String error) = _BalanceError;
}

@freezed
class AddressesState with _$AddressesState {
  const factory AddressesState.initial() = _AddressInitial;
  const factory AddressesState.loading() = _AddressLoading;
  const factory AddressesState.success(List<Address> addresses) =
      _AddressSuccess;
  const factory AddressesState.error(String error) = _AddressError;
}

@freezed
class SubmitState with _$SubmitState {
  const factory SubmitState.initial() = _SubmitInitial;
  const factory SubmitState.loading() = _SubmitLoading;
  const factory SubmitState.composing(
      SubmitStateComposingSend submitStateComposingSend) = _SubmitComposing;
  const factory SubmitState.success(
      String transactionHex, String sourceAddress) = _SubmitSuccess;
  const factory SubmitState.error(String error) = _SubmitError;
}

class SubmitStateComposingSend {
  final ComposeSend composeSend;
  SubmitStateComposingSend({required this.composeSend});
}

class AddressStateSuccess {}

class AddressStateSuccessInitial extends AddressStateSuccess {
  final List<Address> addresses;
  AddressStateSuccessInitial({required this.addresses});
}

class AddressStateError extends AddressStateSuccess {
  final String message;
  AddressStateError({required this.message});
}
