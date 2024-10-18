import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/asset.dart';

import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

part 'compose_fairminter_state.freezed.dart';

@freezed
class ComposeFairminterState with _$ComposeFairminterState, ComposeStateBase {
  const ComposeFairminterState._(); // Added constructor for private use

  const factory ComposeFairminterState({
    // Inherited properties
    required FeeState feeState,
    required BalancesState balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,

    // Fairminter specific properties
    required AssetState assetState,
  }) = _ComposeFairmintState;

  factory ComposeFairminterState.initial() => ComposeFairminterState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: Medium(),
        submitState: const SubmitInitial(),
        assetState: const AssetState.initial(),
      );
}

@freezed
class AssetState with _$AssetState {
  const factory AssetState.initial() = _AssetInitial;
  const factory AssetState.loading() = _AssetLoading;
  const factory AssetState.success(List<Asset> assets) = _AssetSuccess;
  const factory AssetState.error(String error) = _AssetError;
}
