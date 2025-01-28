import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

abstract interface class ComposeBaseBlocInterface<T extends ComposeStateBase> {
  Future<void> onFetchFormData(
      AsyncFormDependenciesRequested event, Emitter<T> emit);
  void onChangeFeeOption(FeeOptionChanged event, Emitter<T> emit);
  void onComposeTransaction(FormSubmitted event, Emitter<T> emit);
  void onFinalizeTransaction(ReviewSubmitted event, Emitter<T> emit);
  void onSignAndBroadcastTransaction(
      SignAndBroadcastFormSubmitted event, Emitter<T> emit);
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

    on<AsyncFormDependenciesRequested>((event, emit) async {
      _errorService.addBreadcrumb(
        type: 'navigation',
        category: 'compose',
        message: '$composePage page opened',
      );

      await onFetchFormData(event, emit);
    });

    on<FeeOptionChanged>(onChangeFeeOption);
    on<FormSubmitted>(onComposeTransaction);
    on<ReviewSubmitted>(onFinalizeTransaction);
    on<SignAndBroadcastFormSubmitted>(onSignAndBroadcastTransaction);
  }

  @override
  Future<void> onFetchFormData(
      AsyncFormDependenciesRequested event, Emitter<T> emit);

  @override
  void onChangeFeeOption(FeeOptionChanged event, Emitter<T> emit);

  @override
  void onComposeTransaction(FormSubmitted event, Emitter<T> emit);

  @override
  void onFinalizeTransaction(ReviewSubmitted event, Emitter<T> emit);

  @override
  void onSignAndBroadcastTransaction(
      SignAndBroadcastFormSubmitted event, Emitter<T> emit);
}
