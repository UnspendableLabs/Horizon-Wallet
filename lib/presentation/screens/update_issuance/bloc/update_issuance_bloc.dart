import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/screens/update_issuance/bloc/update_issuance_state.dart';

class ComposeIssuanceEventParams {
  final String name;
  final int quantity;
  final String description;
  final bool divisible;
  final bool lock;
  final bool reset;

  ComposeIssuanceEventParams({
    required this.name,
    required this.quantity,
    required this.description,
    required this.divisible,
    required this.lock,
    required this.reset,
  });
}

class UpdateIssuanceBloc extends ComposeBaseBloc<UpdateIssuanceState> {
  UpdateIssuanceBloc()
      : super(UpdateIssuanceState(
          submitState: const SubmitInitial(),
          feeOption: FeeOption.Medium(),
          balancesState: const BalancesState.initial(),
          feeState: const FeeState.initial(),
        )) {
    // Event handlers specific to issuance
  }

  @override
  void onChangeFeeOption(ChangeFeeOption event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value));
  }

  @override
  void onFetchFormData(FetchFormData event, emit) async {}

  @override
  void onComposeTransaction(ComposeTransactionEvent event, emit) async {}

  @override
  void onFinalizeTransaction(FinalizeTransactionEvent event, emit) async {}

  @override
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, emit) async {}
}
