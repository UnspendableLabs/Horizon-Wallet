import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

part 'update_issuance_state.freezed.dart';

@freezed
class UpdateIssuanceState with _$UpdateIssuanceState, ComposeStateBase {
  const UpdateIssuanceState._(); // Added constructor for private use

  const factory UpdateIssuanceState({
    // Inherited properties
    required FeeState feeState,
    required BalancesState balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,

    // specific properties
    required AssetState assetState,
  }) = _UpdateIssuanceState;

  factory UpdateIssuanceState.initial() => UpdateIssuanceState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: Medium(),
        submitState: const SubmitInitial(),
        assetState: const AssetState.initial(),
      );
}

@freezed
class AssetState with _$AssetState {
  const factory AssetState.initial() = _AssetStateInitial;
  const factory AssetState.loading() = _AssetStateLoading;
  const factory AssetState.success(Asset asset) = _AssetStateSuccess;
  const factory AssetState.error(String error) = _AssetStateError;
}
