import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/close_dispenser/bloc/close_dispenser_state.dart';
import 'package:horizon/presentation/screens/close_dispenser/usecase/fetch_form_data.dart';
import 'package:logger/logger.dart';

class CloseDispenserBloc extends ComposeBaseBloc<CloseDispenserState> {
  final Logger logger = Logger();
  final ComposeRepository composeRepository;
  final AnalyticsService analyticsService;

  final FetchCloseDispenserFormDataUseCase fetchCloseDispenserFormDataUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;

  CloseDispenserBloc({
    required this.fetchCloseDispenserFormDataUseCase,
    required this.composeTransactionUseCase,
    required this.composeRepository,
    required this.analyticsService,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
  }) : super(CloseDispenserState(
          submitState: const SubmitInitial(),
          feeOption: FeeOption.Medium(),
          balancesState: const BalancesState.initial(),
          feeState: const FeeState.initial(),
          dispensersState: const DispenserState.initial(),
        )) {
    // // Event handlers specific to the dispenser
    // on<ChangeAsset>((e, emit) {});
    // on<ChangeGiveQuantity>((e, emit) {});
    // on<ChangeEscrowQuantity>((e, emit) {});
  }

    @override
  void onFetchFormData(FetchFormData event, emit) async {
    emit(state.copyWith(
        balancesState: const BalancesState.loading(),
        feeState: const FeeState.loading(),
        dispensersState: const DispenserState.loading(),
        submitState: const SubmitInitial()));

    try {
      final (feeEstimates, dispensers) = await fetchCloseDispenserFormDataUseCase.call(event.currentAddress!);

      emit(state.copyWith(
        balancesState: const BalancesState.success([]),
        feeState: FeeState.success(feeEstimates),
        dispensersState: DispenserState.success(dispensers),
      ));
    } on FetchDispenserException catch (e) {
      emit(state.copyWith(
        dispensersState: DispenserState.error(e.message),
      ));
    } on FetchFeeEstimatesException catch (e) {
      emit(state.copyWith(
        feeState: FeeState.error(e.message),
      ));
    } catch (e) {
      emit(state.copyWith(
        balancesState: BalancesState.error('An unexpected error occurred: ${e.toString()}'),
        dispensersState: DispenserState.error('An unexpected error occurred: ${e.toString()}'),
        feeState: FeeState.error('An unexpected error occurred: ${e.toString()}'),
      ));
    }
  }

  @override
  void onChangeFeeOption(ChangeFeeOption event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value));
  }

  @override
  void onComposeTransaction(ComposeTransactionEvent event, emit) async {
    // emit(state.copyWith(submitState: SubmitLoading()));
  }

  @override
  void onFinalizeTransaction(FinalizeTransactionEvent event, emit) async {
    // emit(state.copyWith(submitState: SubmitLoading()));
  }

  @override
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, emit) async {
    // emit(state.copyWith(submitState: SubmitLoading()));
  }
}
