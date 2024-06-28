import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:horizon/remote_data_bloc/remote_data_state.dart';

import 'package:horizon/domain/entities/address.dart';

part "addresses_state.freezed.dart";

@freezed
class AddressesState with _$AddressesState {
  const factory AddressesState.initial() = _Initial;
  const factory AddressesState.loading() = _Loading;
  const factory AddressesState.success(List<Address> addresses) = _Success;
  const factory AddressesState.error(String error) = _Error;
}
