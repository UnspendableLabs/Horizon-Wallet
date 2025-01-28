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
    required DividendXcpFeeState dividendXcpFeeState,
  }) = _ComposeDividendState;

  factory ComposeDividendState.initial() => ComposeDividendState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: Medium(),
        submitState: const FormStep(),
        assetState: const AssetState.initial(),
        dividendXcpFeeState: const DividendXcpFeeState.initial(),
      );
}

@freezed
class AssetState with _$AssetState {
  const factory AssetState.initial() = _AssetInitial;
  const factory AssetState.loading() = _AssetLoading;
  const factory AssetState.success(Asset asset) = _AssetSuccess;
  const factory AssetState.error(String error) = _AssetError;
}

@freezed
class DividendXcpFeeState with _$DividendXcpFeeState {
  const factory DividendXcpFeeState.initial() = _DividendXcpFeeInitial;
  const factory DividendXcpFeeState.loading() = _DividendXcpFeeLoading;
  const factory DividendXcpFeeState.success(int dividendXcpFee) =
      _DividendXcpFeeSuccess;
  const factory DividendXcpFeeState.error(String error) = _DividendXcpFeeError;
}
