import 'package:freezed_annotation/freezed_annotation.dart';

part 'view_address_pk_state.freezed.dart';

@freezed
class ViewAddressPkState with _$ViewAddressPkState {
  const factory ViewAddressPkState.initial(ViewAddressPkStateInitial initial) =
      _Initial;
  const factory ViewAddressPkState.loading() = _Loading;
  const factory ViewAddressPkState.error(String error) = _Error;
  const factory ViewAddressPkState.success(ViewAddressPkStateSuccess succcess) =
      _Success;
}

@freezed
class ViewAddressPkStateInitial with _$ViewAddressPkStateInitial {
  const factory ViewAddressPkStateInitial({String? error}) =
      _ViewAddressPkStateInitial;
}

@freezed
class ViewAddressPkStateSuccess with _$ViewAddressPkStateSuccess {
  const factory ViewAddressPkStateSuccess({
    required String name,
    required String address,
    required String privateKeyWif,
  }) = _ViewAddressPkStateSuccess;
}
