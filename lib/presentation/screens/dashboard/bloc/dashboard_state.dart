import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_state.freezed.dart';

@freezed
class DashboardState with _$DashboardState {
  const factory DashboardState({
    @Default(AddressStateInitial) addressState,
  }) = _DashboardState;
}

abstract class AddressState {}

class AddressStateInitial extends AddressState {}

class AddressStateLoading extends AddressState {}

class AddressStateSuccess extends AddressState {}

class AddressStateError extends AddressState {
  final String message;
  AddressStateError({required this.message});
}
