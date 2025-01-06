import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/asset.dart';

import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

part 'compose_dividend_state.freezed.dart';

@freezed
class ComposeDividendState with _$ComposeDividendState, ComposeStateBase {
  const ComposeDividendState._(); // Private constructor

  const factory ComposeDividendState({
    // Inherited properties
    required FeeState feeState,
    required BalancesState balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,

    // dividend specific properties
    required AssetState assetState,
  }) = _ComposeDividendState;

  factory ComposeDividendState.initial() => ComposeDividendState(
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
  const factory AssetState.success(Asset asset) = _AssetSuccess;
  const factory AssetState.error(String error) = _AssetError;
}
