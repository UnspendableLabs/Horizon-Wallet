import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

abstract interface class ComposeBaseBlocInterface<T extends ComposeStateBase> {
  Future<void> onFetchFormData(FetchFormData event, Emitter<T> emit);
  void onChangeFeeOption(ChangeFeeOption event, Emitter<T> emit);
  void onComposeTransaction(ComposeTransactionEvent event, Emitter<T> emit);
  void onFinalizeTransaction(FinalizeTransactionEvent event, Emitter<T> emit);
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, Emitter<T> emit);
}

abstract class ComposeBaseBloc<T extends ComposeStateBase>
    extends Bloc<ComposeBaseEvent, T> implements ComposeBaseBlocInterface<T> {
  final String composePage;
  late final ErrorService _errorService;

  ComposeBaseBloc(
    super.initialState, {
    required this.composePage,
  }) {
    _errorService = GetIt.I.get<ErrorService>();

    on<FetchFormData>((event, emit) async {
      _errorService.addBreadcrumb(
        type: 'navigation',
        category: 'compose',
        message: '$composePage page opened',
      );

      await onFetchFormData(event, emit);
    });

    on<ChangeFeeOption>(onChangeFeeOption);
    on<ComposeTransactionEvent>(onComposeTransaction);
    on<FinalizeTransactionEvent>(onFinalizeTransaction);
    on<SignAndBroadcastTransactionEvent>(onSignAndBroadcastTransaction);
  }

  @override
  Future<void> onFetchFormData(FetchFormData event, Emitter<T> emit);

  @override
  void onChangeFeeOption(ChangeFeeOption event, Emitter<T> emit);

  @override
  void onComposeTransaction(ComposeTransactionEvent event, Emitter<T> emit);

  @override
  void onFinalizeTransaction(FinalizeTransactionEvent event, Emitter<T> emit);

  @override
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, Emitter<T> emit);
}
