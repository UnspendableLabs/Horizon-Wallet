import 'package:equatable/equatable.dart';
import 'package:horizon/domain/entities/order.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:formz/formz.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/order_repository.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:rxdart/rxdart.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

import 'package:horizon/domain/entities/compose_cancel.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';

enum OfferHashValidationError { required }

class OfferHashInput extends FormzInput<String, OfferHashValidationError> {
  const OfferHashInput.pure() : super.pure('');
  const OfferHashInput.dirty([super.value = '']) : super.dirty();

  @override
  OfferHashValidationError? validator(String value) {
    return value.isNotEmpty ? null : OfferHashValidationError.required;
  }
}

// Events

abstract class FormEvent extends Equatable {
  const FormEvent();

  @override
  List<Object?> get props => [];
}

class InitializeForm extends FormEvent {}

class OfferHashChanged extends FormEvent {
  final String offerHashId;

  const OfferHashChanged(this.offerHashId);

  @override
  List<Object?> get props => [offerHashId];
}

class FeeOptionChanged extends FormEvent {
  final FeeOption.FeeOption feeOption;
  const FeeOptionChanged(this.feeOption);
  @override
  List<Object?> get props => [feeOption];
}

class FormSubmitted extends FormEvent {}

class FormCancelled extends FormEvent {}

class SubmissionFailed extends FormEvent {
  final String errorMessage;

  const SubmissionFailed(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// State

class FormStateModel extends Equatable {
  final RemoteData<List<Order>> orders;

  final RemoteData<FeeEstimates> feeEstimates;
  final FeeOption.FeeOption feeOption;

  final OfferHashInput offerHash;
  // final RemoteData<Asset> offerHashValidationStatus;
  final FormzSubmissionStatus submissionStatus;
  final String? errorMessage;

  const FormStateModel({
    required this.orders,
    required this.feeEstimates,
    required this.feeOption,
    this.offerHash = const OfferHashInput.pure(),
    // required this.offerHashValidationStatus,
    // this.price = cons PriceInput.pure(),
    this.submissionStatus = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  FormStateModel copyWith({
    RemoteData<List<Order>>? orders,
    OfferHashInput? offerHash,
    FormzSubmissionStatus? submissionStatus,
    String? errorMessage,
    FeeOption.FeeOption? feeOption,
    RemoteData<FeeEstimates>? feeEstimates,
  }) {
    return FormStateModel(
      orders: orders ?? this.orders,
      offerHash: offerHash ?? this.offerHash,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      feeEstimates: feeEstimates ?? this.feeEstimates,
      feeOption: feeOption ?? this.feeOption,
    );
  }

  @override
  List<Object?> get props => [
        orders,
        offerHash,
        submissionStatus,
        errorMessage,
        feeEstimates,
        // offerHashValidationStatus,
        feeOption,
      ];
}

class SubmitArgs {
  final String offerHash;
  final int getQuantity;
  final String giveAsset;
  final int giveQuantity;

  final int feeRateSatsVByte;

  SubmitArgs({
    required this.offerHash,
    required this.getQuantity,
    required this.giveAsset,
    required this.giveQuantity,
    required this.feeRateSatsVByte,
  });
}

class OnSubmitSuccessArgs {
  final ComposeCancelResponse response;
  final VirtualSize virtualSize;
  final int feeRate;

  OnSubmitSuccessArgs({
    required this.response,
    required this.virtualSize,
    required this.feeRate,
  });
}

class CancelOrderFormBloc extends Bloc<FormEvent, FormStateModel> {
  final BalanceRepository balanceRepository;
  final AssetRepository assetRepository;
  final currentAddress;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final void Function() onFormCancelled;
  final void Function(OnSubmitSuccessArgs) onSubmitSuccess;

  final ComposeTransactionUseCase composeTransactionUseCase;
  final ComposeRepository composeRepository;
  final OrderRepository orderRepository;

  CancelOrderFormBloc({
    required this.onSubmitSuccess,
    required this.assetRepository,
    required this.balanceRepository,
    required this.currentAddress,
    required this.getFeeEstimatesUseCase,
    required this.composeTransactionUseCase,
    required this.composeRepository,
    required this.onFormCancelled,
    required this.orderRepository,
    String? initialGiveAsset,
    int? initialGiveQuantity,
  }) : super(FormStateModel(
          orders: NotAsked(),
          feeEstimates: NotAsked(),
          feeOption: Medium(),
        )) {
    on<OfferHashChanged>(_onOfferHashChanged, transformer: restartable());
    on<FeeOptionChanged>(_onFeeOptionChanged);

    on<FormSubmitted>(_onFormSubmitted);
    on<FormCancelled>(_onFormCancelled);
    on<SubmissionFailed>(_onSubmissionFailed);

    on<InitializeForm>(_onInitializeForm);
  }

  Future<void> _onInitializeForm(
    InitializeForm event,
    Emitter<FormStateModel> emit,
  ) async {
    emit(state.copyWith(feeEstimates: Loading(), orders: Loading()));

    try {
      final [feeEstimates as FeeEstimates, openOrders as List<Order>] =
          await Future.wait([_fetchFeeEstimates(), _fetchOrders()]);

      emit(state.copyWith(
          feeEstimates: Success(feeEstimates), orders: Success(openOrders)));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: "Error initializing form",
      ));
    }
  }

  void _onOfferHashChanged(
      OfferHashChanged event, Emitter<FormStateModel> emit) async {
    final offerHashInput = OfferHashInput.dirty(event.offerHashId);
    emit(state.copyWith(
      offerHash: offerHashInput,
    ));
  }

  Future<void> _onFeeOptionChanged(
      FeeOptionChanged event, Emitter<FormStateModel> emit) async {
    final nextState = state.copyWith(feeOption: event.feeOption);

    emit(nextState);
  }

  Future<void> _onFormSubmitted(
      FormSubmitted event, Emitter<FormStateModel> emit) async {
    final offerHashInput = OfferHashInput.dirty(state.offerHash.value);

    emit(state.copyWith(
      offerHash: offerHashInput,
    ));

    if (!Formz.validate([
      offerHashInput,
    ])) {
      emit(state.copyWith(submissionStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));

    try {
      final feeRate = _getFeeRate();

      final String offerHash = state.offerHash.value;

      // Making the compose transaction call
      final composeResponse = await composeTransactionUseCase
          .call<ComposeCancelParams, ComposeCancelResponse>(
        source: currentAddress,
        feeRate: feeRate,
        params: ComposeCancelParams(
          source: currentAddress,
          offerHash: offerHash,
        ),
        composeFn: composeRepository.composeCancel,
      );

      final composed = composeResponse.$1;
      final virtualSize = composeResponse.$2;

      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.success,
      ));

      onSubmitSuccess(OnSubmitSuccessArgs(
        response: composed,
        virtualSize: virtualSize,
        feeRate: feeRate,
      ));
    } on ComposeTransactionException catch (e, _) {
      emit(state.copyWith(
          submissionStatus: FormzSubmissionStatus.failure,
          errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
          submissionStatus: FormzSubmissionStatus.failure,
          errorMessage: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  void _onSubmissionFailed(
      SubmissionFailed event, Emitter<FormStateModel> emit) {
    emit(state.copyWith(
      submissionStatus: FormzSubmissionStatus.failure,
      errorMessage: event.errorMessage,
    ));
  }

  void _onFormCancelled(FormCancelled event, Emitter<FormStateModel> emit) {
    emit(state.copyWith(submissionStatus: FormzSubmissionStatus.initial));
    onFormCancelled();
  }

  Future<FeeEstimates> _fetchFeeEstimates() async {
    try {
      return await getFeeEstimatesUseCase.call();
    } catch (e) {
      throw FetchFeeEstimatesException(e.toString());
    }
  }

  Future<List<Order>> _fetchOrders() async {
    try {
      final e =
          await orderRepository.getByAddress(currentAddress, "open").run();
      return e.match(
          (error) => throw FetchOrdersException(error), (success) => success);
    } catch (e) {
      throw FetchOrdersException(e.toString());
    }
  }

  int _getFeeRate() {
    return switch (state.feeEstimates) {
      Success(data: var feeEstimates) => switch (state.feeOption) {
          FeeOption.Fast() => feeEstimates.fast,
          FeeOption.Medium() => feeEstimates.medium,
          FeeOption.Slow() => feeEstimates.slow,
          FeeOption.Custom(fee: var fee) => fee,
        },
      _ => throw Exception("fee? invariant")
    };
  }
}

class FetchOrdersException implements Exception {
  final String message;
  FetchOrdersException(this.message);
  @override
  String toString() => 'FetchOrdersException: $message';
}

class FetchFeeEstimatesException implements Exception {
  final String message;
  FetchFeeEstimatesException(this.message);

  @override
  String toString() => 'FetchFeeEstimatesException: $message';
}

EventTransformer<T> debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}
