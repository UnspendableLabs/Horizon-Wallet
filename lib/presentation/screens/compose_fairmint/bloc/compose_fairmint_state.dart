import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/fairminter.dart';

import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

part 'compose_fairmint_state.freezed.dart';

@freezed
class ComposeFairmintState with _$ComposeFairmintState, ComposeStateBase {
  const ComposeFairmintState._(); // Added constructor for private use

  const factory ComposeFairmintState({
    // Inherited properties
    required FeeState feeState,
    required BalancesState balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,
    String? initialFairminterTxHash,
    Fairminter? selectedFairminter,

    // Fairmint specific properties
    required FairmintersState fairmintersState,
  }) = _ComposeFairmintState;

  factory ComposeFairmintState.initial() => ComposeFairmintState(
      feeState: const FeeState.initial(),
      balancesState: const BalancesState.initial(),
      feeOption: Medium(),
      submitState: const FormStep(),
      fairmintersState: const FairmintersState.initial(),
      initialFairminterTxHash: null,
      selectedFairminter: null);
}

@freezed
class FairmintersState with _$FairmintersState {
  const factory FairmintersState.initial() = _FairmintersInitial;
  const factory FairmintersState.loading() = _FairmintersLoading;
  const factory FairmintersState.success(List<Fairminter> fairminters) =
      _FairmintersSuccess;
  const factory FairmintersState.error(String error) = _FairmintersError;
}
