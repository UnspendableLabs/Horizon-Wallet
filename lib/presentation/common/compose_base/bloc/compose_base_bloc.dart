import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

abstract interface class ComposeBaseBlocInterface<T extends ComposeStateBase> {

  Future<void> onAsyncFormDependenciesRequested(
      AsyncFormDependenciesRequested event, Emitter<T> emit);
  void onFeeOptionChanged(FeeOptionChanged event, Emitter<T> emit);
  void onFormSubmitted(FormSubmitted event, Emitter<T> emit);
  void onReviewSubmitted(ReviewSubmitted event, Emitter<T> emit);
  void onSignAndBroadcastFormSubmitted(
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

      await onAsyncFormDependenciesRequested(event, emit);
    });

    on<FeeOptionChanged>(onFeeOptionChanged);
    on<FormSubmitted>(onFormSubmitted);
    on<ReviewSubmitted>(onReviewSubmitted);
    on<SignAndBroadcastFormSubmitted>(onSignAndBroadcastFormSubmitted);
  }

  @override
  Future<void> onAsyncFormDependenciesRequested(
      AsyncFormDependenciesRequested event, Emitter<T> emit);

  @override
  void onFeeOptionChanged(FeeOptionChanged event, Emitter<T> emit);

  @override
  void onFormSubmitted(FormSubmitted event, Emitter<T> emit);

  @override
  void onReviewSubmitted(ReviewSubmitted event, Emitter<T> emit);

  @override
  void onSignAndBroadcastFormSubmitted(
      SignAndBroadcastFormSubmitted event, Emitter<T> emit) {}
}
