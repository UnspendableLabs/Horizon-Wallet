import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:formz/formz.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:rxdart/rxdart.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

import 'package:horizon/domain/entities/compose_order.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';

enum GiveAssetValidationError { empty }

class GiveAssetInput extends FormzInput<String, GiveAssetValidationError> {
  const GiveAssetInput.pure() : super.pure('');
  const GiveAssetInput.dirty([String value = '']) : super.dirty(value);

  @override
  GiveAssetValidationError? validator(String value) {
    return value.isNotEmpty ? null : GiveAssetValidationError.empty;
  }
}

enum GetAssetValidationError { required }

class GetAssetInput extends FormzInput<String, GetAssetValidationError> {
  const GetAssetInput.pure() : super.pure('');
  const GetAssetInput.dirty([String value = '']) : super.dirty(value);

  @override
  GetAssetValidationError? validator(String value) {
    return value.isNotEmpty ? null : GetAssetValidationError.required;
  }
}

enum PriceValidationError { invalid }

class PriceInput extends FormzInput<String, PriceValidationError> {
  const PriceInput.pure() : super.pure('');
  const PriceInput.dirty([String value = '']) : super.dirty(value);

  @override
  PriceValidationError? validator(String value) {
    final price = double.tryParse(value);
    return (price != null && price > 0) ? null : PriceValidationError.invalid;
  }
}

enum GiveQuantityValidationError { invalid, exceedsBalance, required }

class GiveQuantityInput
    extends FormzInput<String, GiveQuantityValidationError> {
  final int? balance;
  final bool isDivisible;

  const GiveQuantityInput.pure({this.balance, this.isDivisible = false})
      : super.pure('');
  const GiveQuantityInput.dirty(String value,
      {this.balance, this.isDivisible = false})
      : super.dirty(value);

  @override
  GiveQuantityValidationError? validator(String value) {
    if (value == null || value.isEmpty) {
      return GiveQuantityValidationError.required;
    }

    final quantity = isDivisible
        ? (double.tryParse(value)! * 100000000)
        : int.tryParse(value);

    if (quantity == null || quantity <= 0) {
      return GiveQuantityValidationError.invalid;
    }
    if (balance != null && quantity > balance!) {
      return GiveQuantityValidationError.exceedsBalance;
    }
    return null;
  }
}

enum GetQuantityValidationError { invalid, required }

class GetQuantityInput extends FormzInput<String, GetQuantityValidationError> {
  final bool isDivisible;

  const GetQuantityInput.pure({this.isDivisible = false}) : super.pure('');

  const GetQuantityInput.dirty(String value, {this.isDivisible = false})
      : super.dirty(value);

  @override
  GetQuantityValidationError? validator(String value) {
    if (value == null || value.isEmpty) {
      return GetQuantityValidationError.required;
    }

    final quantity = isDivisible
        ? (double.tryParse(value)! * 100000000)
        : int.tryParse(value);

    if (quantity == null || quantity <= 0) {
      return GetQuantityValidationError.invalid;
    }
    return null;
  }
}

// Events

abstract class FormEvent extends Equatable {
  const FormEvent();

  @override
  List<Object?> get props => [];
}

class InitializeParams {
  final String initialGiveAsset;
  final int initialGiveQuantity;
  final String initialGetAsset;
  final int initialGetQuantity;

  InitializeParams({
    required this.initialGiveAsset,
    required this.initialGiveQuantity,
    required this.initialGetAsset,
    required this.initialGetQuantity,
  });
}

class InitializeForm extends FormEvent {
  final InitializeParams? params;

  const InitializeForm({this.params});

  @override
  List<Object?> get props => [
        params?.initialGetQuantity,
        params?.initialGetAsset,
        params?.initialGiveQuantity,
        params?.initialGiveAsset
      ];
}

class GiveAssetChanged extends FormEvent {
  final String giveAssetId;

  const GiveAssetChanged(this.giveAssetId);

  @override
  List<Object?> get props => [giveAssetId];
}

class GetAssetChanged extends FormEvent {
  final String getAssetId;

  const GetAssetChanged(this.getAssetId);

  @override
  List<Object?> get props => [getAssetId];
}

class GiveQuantityChanged extends FormEvent {
  final String value;

  const GiveQuantityChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class GetQuantityChanged extends FormEvent {
  final String value;

  const GetQuantityChanged(this.value);

  @override
  List<Object?> get props => [value];
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
  final RemoteData<FeeEstimates> feeEstimates;
  final FeeOption.FeeOption feeOption;

  final RemoteData<List<Balance>> giveAssets;
  final RemoteData<List<Asset>> getAssets;
  final GiveAssetInput giveAsset;
  final GiveQuantityInput giveQuantity;
  final GetAssetInput getAsset;
  final RemoteData<Asset> getAssetValidationStatus;
  final GetQuantityInput getQuantity;
  // final PriceInput price;
  final FormzSubmissionStatus submissionStatus;
  final String? errorMessage;

  const FormStateModel({
    required this.feeEstimates,
    required this.feeOption,
    required this.giveAssets,
    required this.getAssets,
    this.giveAsset = const GiveAssetInput.pure(),
    this.giveQuantity = const GiveQuantityInput.pure(),
    this.getAsset = const GetAssetInput.pure(),
    required this.getAssetValidationStatus,
    this.getQuantity = const GetQuantityInput.pure(),
    // this.price = cons PriceInput.pure(),
    this.submissionStatus = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  FormStateModel copyWith({
    RemoteData<List<Balance>>? giveAssets,
    RemoteData<List<Asset>>? getAssets,
    GiveAssetInput? giveAsset,
    GiveQuantityInput? giveQuantity,
    GetAssetInput? getAsset,
    GetQuantityInput? getQuantity,
    PriceInput? price,
    FormzSubmissionStatus? submissionStatus,
    String? errorMessage,
    RemoteData<Asset>? getAssetValidationStatus,
    FeeOption.FeeOption? feeOption,
    RemoteData<FeeEstimates>? feeEstimates,
  }) {
    return FormStateModel(
      giveAssets: giveAssets ?? this.giveAssets,
      getAssets: getAssets ?? this.getAssets,
      giveAsset: giveAsset ?? this.giveAsset,
      giveQuantity: giveQuantity ?? this.giveQuantity,
      getAsset: getAsset ?? this.getAsset,
      getQuantity: getQuantity ?? this.getQuantity,
      getAssetValidationStatus:
          getAssetValidationStatus ?? this.getAssetValidationStatus,
      // price: price ?? this.price,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      feeEstimates: feeEstimates ?? this.feeEstimates,
      feeOption: feeOption ?? this.feeOption,
    );
  }

  @override
  List<Object?> get props => [
        giveAssets,
        getAssets,
        giveAsset,
        giveQuantity,
        getAsset,
        getQuantity,
        submissionStatus,
        errorMessage,
        getAssetValidationStatus,
        feeOption,
      ];
}

class SubmitArgs {
  final String getAsset;
  final int getQuantity;
  final String giveAsset;
  final int giveQuantity;

  final int feeRateSatsVByte;

  SubmitArgs({
    required this.getAsset,
    required this.getQuantity,
    required this.giveAsset,
    required this.giveQuantity,
    required this.feeRateSatsVByte,
  });
}

class OnSubmitSuccessArgs {
  final ComposeOrderResponse response;
  final VirtualSize virtualSize;
  final int feeRate;

  OnSubmitSuccessArgs({
    required this.response,
    required this.virtualSize,
    required this.feeRate,
  });
}

class OpenOrderFormBloc extends Bloc<FormEvent, FormStateModel> {
  final BalanceRepository balanceRepository;
  final AssetRepository assetRepository;
  final currentAddress;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final void Function() onFormCancelled;
  final void Function(OnSubmitSuccessArgs) onSubmitSuccess;

  final ComposeTransactionUseCase composeTransactionUseCase;
  final ComposeRepository composeRepository;

  OpenOrderFormBloc({
    required this.onSubmitSuccess,
    required this.assetRepository,
    required this.balanceRepository,
    required this.currentAddress,
    required this.getFeeEstimatesUseCase,
    required this.composeTransactionUseCase,
    required this.composeRepository,
    required this.onFormCancelled,
    String? initialGiveAsset,
    int? initialGiveQuantity,
  }) : super(FormStateModel(
          giveAssets: NotAsked(),
          getAssets: NotAsked(),
          getAssetValidationStatus: NotAsked(),
          feeEstimates: NotAsked(),
          feeOption: Medium(),
        )) {
    on<GiveAssetChanged>(_onGiveAssetChanged);
    on<GetAssetChanged>(_onGetAssetChanged, transformer: restartable());
    on<GetQuantityChanged>(_onGetQuantityChanged);
    on<GiveQuantityChanged>(_onGiveQuantityChanged);
    on<FeeOptionChanged>(_onFeeOptionChanged);

    on<FormSubmitted>(_onFormSubmitted);
    on<FormCancelled>(_onFormCancelled);
    on<InitializeForm>(_onInitializeForm);
    on<SubmissionFailed>(_onSubmissionFailed);
  }
  Future<void> _onInitializeForm(
    InitializeForm event,
    Emitter<FormStateModel> emit,
  ) async {
    emit(state.copyWith(giveAssets: Loading(), feeEstimates: Loading()));

    try {
      final [balances_ as List<Balance>, feeEstimates as FeeEstimates] =
          await Future.wait([
        balanceRepository.getBalancesForAddress(currentAddress),
        _fetchFeeEstimates(),
      ]);

      final balances = balances_
          .where((balance) => balance.asset.toUpperCase() != "BTC")
          .toList();

      if (event.params == null) {
        emit(state.copyWith(
            giveAssets: Success(balances),
            feeEstimates: Success(feeEstimates)));
      } else {
        final InitializeParams params = event.params!;

        final balanceForAsset = balances.firstWhereOrNull(
          (balance) =>
              balance.asset.toLowerCase() ==
              params.initialGiveAsset.toLowerCase(),
        );

        if (balanceForAsset == null) {
          // Case: No balance for the initial asset
          emit(state.copyWith(
            giveAssets: Success(balances),
            feeEstimates: Success(feeEstimates),
            errorMessage:
                'No balance available for the initial asset ${params.initialGiveAsset}',
          ));
          return;
        }

        int initialGiveQuantity = event.params!.initialGiveQuantity;

        final initialGiveQuantityNormalized =
            balanceForAsset.assetInfo.divisible
                ? (initialGiveQuantity / 100000000)
                : initialGiveQuantity;

        if (initialGiveQuantity > balanceForAsset.quantity) {
          // Case: Insufficient balance
          emit(state.copyWith(
            giveAsset: GiveAssetInput.dirty(balanceForAsset.asset),
            giveAssets: Success(balances),
            feeEstimates: Success(feeEstimates),
            giveQuantity: GiveQuantityInput.dirty(
              initialGiveQuantityNormalized.toString(),
              balance: balanceForAsset.quantity,
              isDivisible: balanceForAsset.assetInfo.divisible,
            ),
            errorMessage:
                'Insufficient balance for the initial quantity of $initialGiveQuantity',
          ));
        } else {
          // there is adequate give asset balance
          emit(state.copyWith(
            giveAsset: GiveAssetInput.dirty(balanceForAsset.asset),
            giveAssets: Success(balances),
            feeEstimates: Success(feeEstimates),
            giveQuantity: GiveQuantityInput.dirty(
              initialGiveQuantityNormalized.toString(),
              balance: balanceForAsset.quantity,
              isDivisible: balanceForAsset.assetInfo.divisible,
            ),
          ));

          // now validate the get asset

          emit(state.copyWith(
            getAsset: GetAssetInput.dirty(params.initialGetAsset),
            getAssetValidationStatus: Loading(),
          ));

          try {
            final asset =
                await assetRepository.getAssetVerbose(params.initialGetAsset);

            int initialGetQuantity = event.params!.initialGetQuantity;

            final initialGetQuantityNormalized = asset.divisible ?? false
                ? (initialGetQuantity / 100000000)
                : initialGetQuantity;

            emit(state.copyWith(
              getQuantity: GetQuantityInput.dirty(
                initialGetQuantityNormalized.toString(),
                isDivisible: asset.divisible ?? false,
              ),
              getAssetValidationStatus: Success(asset),
            ));
          } catch (e) {
            emit(state.copyWith(
              getAssetValidationStatus: Failure('Asset not found'),
            ));
            return;
          }
        }
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: "Invalid order details",
      ));
    }
  }

  void _onGiveAssetChanged(
      GiveAssetChanged event, Emitter<FormStateModel> emit) {
    final giveAssetInput = GiveAssetInput.dirty(event.giveAssetId);

    final balance = _getBalanceForAsset(event.giveAssetId);

    final giveQuantity = GiveQuantityInput.dirty(
      state.giveQuantity.value,
      isDivisible: balance?.assetInfo.divisible ?? false,
    );

    emit(state.copyWith(
      giveQuantity: giveQuantity,
      giveAsset: giveAssetInput,
      errorMessage: null,
    ));
  }

  void _onGetAssetChanged(
      GetAssetChanged event, Emitter<FormStateModel> emit) async {
    final getAssetInput = GetAssetInput.dirty(event.getAssetId);
    emit(state.copyWith(
      getAsset: getAssetInput,
      getAssetValidationStatus: Loading(),
    ));
    try {
      final asset = await assetRepository.getAssetVerbose(event.getAssetId);

      final getQuantityInput = GetQuantityInput.dirty(
        state.getQuantity.value,
        isDivisible: asset.divisible ?? false,
      );

      emit(state.copyWith(
        getQuantity: getQuantityInput,
        getAssetValidationStatus: Success(asset),
      ));
    } catch (e) {
      emit(state.copyWith(
        getAssetValidationStatus: Failure('Asset not found'),
      ));
    }
  }

  void _onGetQuantityChanged(
      GetQuantityChanged event, Emitter<FormStateModel> emit) {
    final isDivisible = switch (state.getAssetValidationStatus) {
      Success(data: var asset) => asset.divisible!,
      _ =>
        true, // default to true ( i.e. let user specify decimal if no asset selected)
    };

    final input = GetQuantityInput.dirty(event.value, isDivisible: isDivisible);
    emit(state.copyWith(getQuantity: input, errorMessage: null));
  }

  void _onGiveQuantityChanged(
      GiveQuantityChanged event, Emitter<FormStateModel> emit) {
    final balance = _getBalanceForAsset(state.giveAsset.value);

    if (balance == null) {
      // if we don't have a balance we permit divisibility
      final input = GiveQuantityInput.dirty(event.value, isDivisible: true);

      emit(state.copyWith(
        giveQuantity: input,
      ));
      return;
    }

    final input = GiveQuantityInput.dirty(event.value,
        balance: balance?.quantity,
        isDivisible: balance?.assetInfo.divisible ?? false);

    emit(state.copyWith(giveQuantity: input, errorMessage: null));
  }

  Future<void> _onFeeOptionChanged(
      FeeOptionChanged event, Emitter<FormStateModel> emit) async {
    final nextState = state.copyWith(feeOption: event.feeOption);

    emit(nextState);
  }

  Future<void> _onFormSubmitted(
      FormSubmitted event, Emitter<FormStateModel> emit) async {
    final giveAssetInput = GiveAssetInput.dirty(state.giveAsset.value);
    final getAssetInput = GetAssetInput.dirty(state.getAsset.value);
    final giveQuantityInput = GiveQuantityInput.dirty(
      state.giveQuantity.value,
      balance: _getBalanceForAsset(state.giveAsset.value)?.quantity,
      isDivisible: state.giveQuantity.isDivisible,
    );
    final getQuantityInput = GetQuantityInput.dirty(
      state.getQuantity.value,
      isDivisible: state.getQuantity.isDivisible,
    );


    emit(state.copyWith(
      giveAsset: giveAssetInput,
      getAsset: getAssetInput,
      giveQuantity: giveQuantityInput,
      getQuantity: getQuantityInput,
    ));

    if (!Formz.validate([
      giveAssetInput,
      getAssetInput,
      giveQuantityInput,
      getQuantityInput,
    ])) {
      emit(state.copyWith(submissionStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));

    try {
      final feeRate = _getFeeRate();

      final String getAsset = state.getAsset.value;
      final String giveAsset = state.giveAsset.value;
      final int getQuantity = (state.getQuantity.isDivisible
          ? (double.parse(state.getQuantity.value) * 100000000).round()
          : int.parse(state.getQuantity.value));
      final int giveQuantity = (state.giveQuantity.isDivisible
          ? (double.parse(state.giveQuantity.value) * 100000000).round()
          : int.parse(state.giveQuantity.value));

      // Making the compose transaction call
      final composeResponse = await composeTransactionUseCase
          .call<ComposeOrderParams, ComposeOrderResponse>(
        source: currentAddress,
        feeRate: feeRate,
        params: ComposeOrderParams(
          source: currentAddress,
          giveQuantity: giveQuantity,
          giveAsset: giveAsset,
          getQuantity: getQuantity,
          getAsset: getAsset,
        ),
        composeFn: composeRepository.composeOrder,
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
      return await getFeeEstimatesUseCase.call(targets: (1, 3, 6));
    } catch (e) {
      throw FetchFeeEstimatesException(e.toString());
    }
  }

  int _getFeeRate() {
    return switch (state.feeEstimates) {
      Success(data: var feeEstimates) => switch (
            state.feeOption as FeeOption.FeeOption) {
          FeeOption.Fast() => feeEstimates.fast,
          FeeOption.Medium() => feeEstimates.medium,
          FeeOption.Slow() => feeEstimates.slow,
          FeeOption.Custom(fee: var fee) => fee,
        },
      _ => throw Exception("invariant")
    };
  }

  Balance? _getBalanceForAsset(String assetId) {
    return switch (state.giveAssets) {
      Success(data: var data) =>
        data.firstWhereOrNull((balance) => balance.asset == assetId),
      _ => null,
    };
  }
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
