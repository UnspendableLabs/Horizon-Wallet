import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:formz/formz.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

import 'package:horizon/domain/entities/compose_order.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';
import 'package:fpdart/fpdart.dart';

enum GiveAssetValidationError { required }

class GiveAssetInput extends FormzInput<String, GiveAssetValidationError> {
  const GiveAssetInput.pure() : super.pure('');
  const GiveAssetInput.dirty(super.value) : super.dirty();

  @override
  GiveAssetValidationError? validator(String value) {
    if (value.isEmpty) {
      return GiveAssetValidationError.required;
    }
    return null;
  }
}

enum GetAssetValidationError { required }

class GetAssetInput extends FormzInput<String, GetAssetValidationError> {
  const GetAssetInput.pure() : super.pure('');
  const GetAssetInput.dirty([super.value = '']) : super.dirty();

  @override
  GetAssetValidationError? validator(String value) {
    return value.isNotEmpty ? null : GetAssetValidationError.required;
  }
}

enum PriceValidationError { invalid }

class PriceInput extends FormzInput<String, PriceValidationError> {
  const PriceInput.pure() : super.pure('');
  const PriceInput.dirty([super.value = '']) : super.dirty();

  @override
  PriceValidationError? validator(String value) {
    final price = double.tryParse(value);
    return (price != null && price > 0) ? null : PriceValidationError.invalid;
  }
}

enum GiveQuantityValidationError { invalid, exceedsBalance, required }

class GiveQuantityInput extends FormzInput<String, GiveQuantityValidationError>
    with EquatableMixin {
  final int? balance;
  final bool isDivisible;

  const GiveQuantityInput.pure({this.balance, this.isDivisible = false})
      : super.pure('');
  const GiveQuantityInput.dirty(super.value,
      {this.balance, this.isDivisible = false})
      : super.dirty();

  @override
  List<Object?> get props => [value, isPure, error, balance, isDivisible];

  @override
  GiveQuantityValidationError? validator(String value) {
    if (value.isEmpty) {
      return GiveQuantityValidationError.required;
    }

    try {
      final quantity = isDivisible
          ? (double.tryParse(value)! * SATOSHI_RATE)
          : int.tryParse(value);

      if (quantity == null || quantity <= 0) {
        return GiveQuantityValidationError.invalid;
      }

      if (balance == null || balance != null && quantity > balance!) {
        return GiveQuantityValidationError.exceedsBalance;
      }

      return null;
    } catch (e) {
      return GiveQuantityValidationError.invalid;
    }
  }
}

enum GetQuantityValidationError { invalid, required }

class GetQuantityInput extends FormzInput<String, GetQuantityValidationError>
    with EquatableMixin {
  final bool isDivisible;

  const GetQuantityInput.pure({this.isDivisible = false}) : super.pure('');

  const GetQuantityInput.dirty(super.value, {this.isDivisible = false})
      : super.dirty();

  @override
  List<Object?> get props => [value, isPure, error, isDivisible];

  @override
  GetQuantityValidationError? validator(String value) {
    if (value.isEmpty) {
      return GetQuantityValidationError.required;
    }

    try {
      final quantity = isDivisible
          ? (double.tryParse(value)! * SATOSHI_RATE)
          : int.tryParse(value);

      if (quantity == null || quantity <= 0) {
        return GetQuantityValidationError.invalid;
      }
      return null;
    } catch (e) {
      return GetQuantityValidationError.invalid;
    }
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

class GiveAssetBlurred extends FormEvent {}

class GetAssetBlurred extends FormEvent {}

class GiveQuantityBlurred extends FormEvent {}

class GetQuantityBlurred extends FormEvent {}

class LockRatioChanged extends FormEvent {
  final bool lockRatio;

  const LockRatioChanged(this.lockRatio);

  @override
  List<Object?> get props => [lockRatio];
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
} // State

class FormStateModel extends Equatable {
  final RemoteData<FeeEstimates> feeEstimates;
  final FeeOption.FeeOption feeOption;

  final RemoteData<List<Balance>> giveAssets;
  final GiveAssetInput giveAsset;
  final GiveQuantityInput giveQuantity;
  final GetAssetInput getAsset;
  final RemoteData<Asset> getAssetValidationStatus;
  final RemoteData<Asset> giveAssetValidationStatus;

  final GetQuantityInput getQuantity;
  // final PriceInput price;
  final FormzSubmissionStatus submissionStatus;
  final String? errorMessage;

  final bool lockRatio;
  final Option<Rational> ratio;

  const FormStateModel(
      {required this.feeEstimates,
      required this.feeOption,
      required this.giveAssets,
      this.giveAsset = const GiveAssetInput.pure(),
      this.giveQuantity = const GiveQuantityInput.pure(),
      this.getAsset = const GetAssetInput.pure(),
      required this.getAssetValidationStatus,
      required this.giveAssetValidationStatus,
      this.getQuantity = const GetQuantityInput.pure(),
      // this.price = cons PriceInput.pure(),
      this.submissionStatus = FormzSubmissionStatus.initial,
      this.errorMessage,
      this.lockRatio = false,
      this.ratio = const Option.none()});

  FormStateModel copyWith({
    RemoteData<List<Balance>>? giveAssets,
    GiveAssetInput? giveAsset,
    GiveQuantityInput? giveQuantity,
    GetAssetInput? getAsset,
    GetQuantityInput? getQuantity,
    PriceInput? price,
    FormzSubmissionStatus? submissionStatus,
    String? errorMessage,
    RemoteData<Asset>? getAssetValidationStatus,
    RemoteData<Asset>? giveAssetValidationStatus,
    FeeOption.FeeOption? feeOption,
    RemoteData<FeeEstimates>? feeEstimates,
    bool? lockRatio,
    Option<Rational>? ratio,
  }) {
    return FormStateModel(
        giveAssets: giveAssets ?? this.giveAssets,
        giveAsset: giveAsset ?? this.giveAsset,
        giveQuantity: giveQuantity ?? this.giveQuantity,
        getAsset: getAsset ?? this.getAsset,
        getQuantity: getQuantity ?? this.getQuantity,
        getAssetValidationStatus:
            getAssetValidationStatus ?? this.getAssetValidationStatus,
        giveAssetValidationStatus:
            giveAssetValidationStatus ?? this.giveAssetValidationStatus,
        // price: price ?? this.price,
        submissionStatus: submissionStatus ?? this.submissionStatus,
        errorMessage: errorMessage ?? this.errorMessage,
        feeEstimates: feeEstimates ?? this.feeEstimates,
        feeOption: feeOption ?? this.feeOption,
        lockRatio: lockRatio ?? this.lockRatio,
        ratio: ratio ?? this.ratio);
  }

  @override
  List<Object?> get props => [
        giveAssets,
        giveAsset,
        giveQuantity,
        getAsset,
        getQuantity,
        submissionStatus,
        errorMessage,
        getAssetValidationStatus,
        giveAssetValidationStatus,
        feeOption,
        lockRatio,
        ratio
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
  final num feeRate;

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
  final HttpConfig httpConfig;

  
  OpenOrderFormBloc({
    required this.httpConfig,
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
          getAssetValidationStatus: NotAsked(),
          giveAssetValidationStatus: NotAsked(),
          feeEstimates: NotAsked(),
          feeOption: Medium(),
        )) {
    on<GiveAssetChanged>(_onGiveAssetChanged);
    on<GetAssetChanged>(_onGetAssetChanged);
    on<GetAssetBlurred>(_onGetAssetBlurred);
    on<GiveAssetBlurred>(_onGiveAssetBlurred);
    on<GetQuantityChanged>(_onGetQuantityChanged);
    on<GetQuantityBlurred>(_onGetQuantityBlurred); //
    on<GiveQuantityChanged>(_onGiveQuantityChanged);
    on<GiveQuantityBlurred>(_onGiveQuantityBlurred);
    on<FeeOptionChanged>(_onFeeOptionChanged);

    on<FormSubmitted>(_onFormSubmitted);
    on<FormCancelled>(_onFormCancelled);
    on<InitializeForm>(_onInitializeForm);
    on<SubmissionFailed>(_onSubmissionFailed);
    on<LockRatioChanged>(_onLockRatioChanged);
  }
  void _onLockRatioChanged(
    LockRatioChanged event,
    Emitter<FormStateModel> emit,
  ) {
    final lockRatio = event.lockRatio;

    if (lockRatio) {
      // Attempt to parse both quantities
      final giveQuantity = Decimal.tryParse(state.giveQuantity.value);
      final getQuantity = Decimal.tryParse(state.getQuantity.value);

      if (getQuantity != null &&
          getQuantity > Decimal.zero &&
          giveQuantity != null &&
          giveQuantity > Decimal.zero) {
        final ratio = giveQuantity / getQuantity;
        emit(state.copyWith(
          lockRatio: true,
          ratio: Option.of(ratio),
          errorMessage: null, // Clear any previous errors
        ));
      } else {
        // Cannot lock ratio due to invalid quantities
        emit(state.copyWith(
          lockRatio: false, // Ensure lock ratio is disabled
          ratio: const Option.none(),
          errorMessage: 'Cannot lock ratio: invalid quantities.',
        ));
      }
    } else {
      // Unlock ratio
      emit(state.copyWith(
        lockRatio: false,
        ratio: const Option.none(),
        errorMessage: null, // Clear any previous errors
      ));
    }
  }

  _handleInitialize(InitializeForm event, Emitter<FormStateModel> emit) async {
    emit(state.copyWith(
      giveAssets: Loading(),
      feeEstimates: Loading<FeeEstimates>(),
    ));

    final [balances_ as List<Balance>, feeEstimates_ as FeeEstimates] =
        await Future.wait([
      balanceRepository.getBalancesForAddress(address: currentAddress, excludeUtxoAttached: true, httpConfig: httpConfig),
      _fetchFeeEstimates(),
    ]);

    final balances = balances_
        .where((balance) => balance.asset.toUpperCase() != "BTC")
        .toList();

    emit(state.copyWith(
        giveAssets: Success(balances),
        feeEstimates: Success<FeeEstimates>(feeEstimates_)));
  }

  Future<void> _onInitializeForm(
    InitializeForm event,
    Emitter<FormStateModel> emit,
  ) async {
    if (event.params == null) {
      return _handleInitialize(event, emit);
    }
    final InitializeParams params = event.params!;

    GiveAssetInput giveAsset = GiveAssetInput.dirty(params.initialGiveAsset);

    GetAssetInput getAsset = GetAssetInput.dirty(params.initialGetAsset);

    emit(state.copyWith(
      lockRatio: true,
      giveAsset: giveAsset,
      getAsset: getAsset,
      giveAssets: Loading(),
      feeEstimates: Loading<FeeEstimates>(),
      getAssetValidationStatus: Loading(),
      giveAssetValidationStatus: Loading(),
    ));

    late RemoteData<List<Balance>> nextGiveAssets;
    late RemoteData<FeeEstimates> nextFeeEstimates;

    late GiveAssetInput nextGiveAsset;
    late GiveQuantityInput nextGiveQuantity;
    late RemoteData<Asset> nextGiveAssetValidationStatus;
    late GetAssetInput nextGetAsset;
    late GetQuantityInput nextGetQuantity;
    late RemoteData<Asset> nextGetAssetValidationStatus;

    final getBalancesTaskEither = TaskEither.tryCatch(
      () => balanceRepository.getBalancesForAddress(address: currentAddress, excludeUtxoAttached: true, httpConfig: httpConfig),
      (error, stacktrace) => 'Error fetching balances',
    );

    final getFeeEstimatesTaskEither = TaskEither.tryCatch(
      () => _fetchFeeEstimates(),
      (error, stacktrace) => 'Error fetching fee estimates',
    );

    final getGiveAssetTaskEither = TaskEither.tryCatch(
      () => assetRepository.getAssetVerbose(assetName: params.initialGiveAsset, httpConfig: httpConfig),
      (error, stacktrace) => 'Error fetching give asset',
    );

    final getGetAssetTaskEither = TaskEither.tryCatch(
      () => assetRepository.getAssetVerbose(assetName: params.initialGetAsset, httpConfig: httpConfig),
      (error, stacktrace) => 'Error fetching get asset',
    );

    final results = await Future.wait([
      getBalancesTaskEither.run(),
      getFeeEstimatesTaskEither.run(),
      getGiveAssetTaskEither.run(),
      getGetAssetTaskEither.run(),
    ]);

    nextGiveAssets = (results[0] as Either<String, List<Balance>>).fold(
      (error) => Failure(error),
      (balances) => Success(balances),
    );

    nextFeeEstimates = (results[1] as Either<String, FeeEstimates>).fold(
      (error) => Failure(error),
      (feeEstimates) => Success(feeEstimates),
    );

    try {
      final initialGiveBalance = switch (nextGiveAssets) {
        Success(data: var data) => data.firstWhereOrNull(
            (balance) =>
                balance.asset.toLowerCase() ==
                params.initialGiveAsset.toLowerCase(),
          ),
        _ => null
      };

      final initialGiveAsset =
          await assetRepository.getAssetVerbose(assetName: params.initialGiveAsset, httpConfig: httpConfig);
      nextGiveAsset = GiveAssetInput.dirty(params.initialGiveAsset);
      nextGiveAssetValidationStatus = Success(initialGiveAsset);
      String nextGiveQuantityNormalized = (initialGiveAsset.divisible ?? false
              ? (params.initialGiveQuantity / SATOSHI_RATE)
              : params.initialGiveQuantity)
          .toString();

      nextGiveQuantity = GiveQuantityInput.dirty(
        nextGiveQuantityNormalized,
        balance: initialGiveBalance?.quantity ?? 0,
        isDivisible: initialGiveAsset.divisible!,
      );
    } catch (e) {
      // if we can't find a give asset, just treat input as divisible
      nextGiveAsset =
          GiveAssetInput.dirty(params.initialGiveAsset); // Keep the input
      nextGiveAssetValidationStatus = Failure("Asset not found");
      nextGiveQuantity = GiveQuantityInput.dirty(
          params.initialGiveQuantity.toString(),
          isDivisible: true);
    }

    try {
      final initialGetAsset =
          await assetRepository.getAssetVerbose(assetName: params.initialGetAsset, httpConfig: httpConfig);
      nextGetAsset = GetAssetInput.dirty(params.initialGetAsset);
      nextGetAssetValidationStatus = Success(initialGetAsset);
      String nextGetQuantityNormalized = (initialGetAsset.divisible ?? false
              ? (params.initialGetQuantity / SATOSHI_RATE)
              : params.initialGetQuantity)
          .toString();
      nextGetQuantity = GetQuantityInput.dirty(nextGetQuantityNormalized,
          isDivisible: initialGetAsset.divisible!);
    } catch (e) {
      nextGetAsset =
          GetAssetInput.dirty(params.initialGetAsset); // Keep the input
      nextGetAssetValidationStatus = Failure("Asset not found");
      nextGetQuantity =
          GetQuantityInput.dirty(params.initialGetQuantity.toString());
    }

    Rational ratio = Decimal.parse(nextGiveQuantity.value) /
        Decimal.parse(nextGetQuantity.value);

    emit(state.copyWith(
      ratio: Option.of(ratio),
      giveAssets: nextGiveAssets,
      feeEstimates: nextFeeEstimates,
      giveAsset: nextGiveAsset,
      giveQuantity: nextGiveQuantity,
      giveAssetValidationStatus: nextGiveAssetValidationStatus,
      getAsset: nextGetAsset,
      getQuantity: nextGetQuantity,
      getAssetValidationStatus: nextGetAssetValidationStatus,
    ));
  }

  void _onGiveAssetChanged(
      GiveAssetChanged event, Emitter<FormStateModel> emit) {
    final giveAssetInput = GiveAssetInput.dirty(event.giveAssetId);

    emit(state.copyWith(
      ratio: const Option.none(),
      lockRatio: false,
      // giveQuantity: giveQuantity,
      giveAsset: giveAssetInput,
      errorMessage: null,
    ));
  }

  void _onGetAssetChanged(
      GetAssetChanged event, Emitter<FormStateModel> emit) async {
    final getAssetInput = GetAssetInput.dirty(event.getAssetId);

    emit(state.copyWith(
      ratio: const Option.none(),
      lockRatio: false,
      getAsset: getAssetInput,
      getAssetValidationStatus: NotAsked(),
    ));
  }

  void _onGetAssetBlurred(
      GetAssetBlurred event, Emitter<FormStateModel> emit) async {
    emit(state.copyWith(
      getAssetValidationStatus: Loading(),
    ));

    try {
      final asset = await assetRepository.getAssetVerbose(assetName: state.getAsset.value, httpConfig: httpConfig);

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

  void _onGiveAssetBlurred(
      GiveAssetBlurred event, Emitter<FormStateModel> emit) async {
    emit(state.copyWith(
      giveAssetValidationStatus: Loading(),
    ));

    try {
      final asset =
          await assetRepository.getAssetVerbose(assetName: state.giveAsset.value, httpConfig: httpConfig);

      final balance = _getBalanceForAsset(state.giveAsset.value);

      final giveQuantityInput = GiveQuantityInput.dirty(
          state.giveQuantity.value,
          isDivisible: asset.divisible ?? false,
          balance: balance?.quantity ?? 0);

      emit(state.copyWith(
        giveQuantity: giveQuantityInput,
        giveAssetValidationStatus: Success(asset),
      ));
    } catch (e) {
      emit(state.copyWith(
        giveAssetValidationStatus: Failure('Asset not found'),
      ));
    }
  }

  void _onGetQuantityChanged(
      GetQuantityChanged event, Emitter<FormStateModel> emit) {
    // assume it's divisble until we blur
    final input = GetQuantityInput.dirty(event.value, isDivisible: true);

    if (state.lockRatio && state.ratio.isSome()) {
      final get = Decimal.tryParse(event.value);
      final give = Decimal.tryParse(state.giveQuantity.value);
      final ratio = state.ratio
          .fold(() => throw Exception("invariant"), (ratio) => ratio);

      if (give != null && get != null) {
        final newGive = (get *
                Decimal.fromBigInt(ratio.numerator) /
                Decimal.fromBigInt(ratio.denominator))
            .toDecimal(scaleOnInfinitePrecision: 8);

        emit(state.copyWith(
          getQuantity: input,
          giveQuantity: GiveQuantityInput.dirty(formatDecimal(newGive),
              balance: state.giveQuantity.balance,
              isDivisible: state.giveQuantity.isDivisible),
        ));
        return;
      }
    }

    emit(state.copyWith(getQuantity: input, errorMessage: null));
  }

  void _onGetQuantityBlurred(
      GetQuantityBlurred event, Emitter<FormStateModel> emit) {
    final value = state.getQuantity.value;

    final isDivisible = switch (state.getAssetValidationStatus) {
      Success(data: var asset) => asset.divisible!,
      _ =>
        true, // default to true ( i.e. let user specify decimal if no asset selected)
    };

    final input = GetQuantityInput.dirty(value, isDivisible: isDivisible);
    emit(state.copyWith(getQuantity: input, errorMessage: null));
  }

  void _onGiveQuantityChanged(
      GiveQuantityChanged event, Emitter<FormStateModel> emit) {
    // Create a new GiveQuantityInput with the updated value
    final input = GiveQuantityInput.dirty(event.value, isDivisible: true);

    if (state.lockRatio && state.ratio.isSome()) {
      final give = Decimal.tryParse(event.value) ?? Decimal.one;
      final get = Decimal.tryParse(state.getQuantity.value);
      final ratio = state.ratio
          .fold(() => throw Exception("invariant"), (ratio) => ratio);

      if (get != null) {
        // Use the stored ratio to compute the new getQuantity

        final newGet = (give *
                Decimal.fromBigInt(ratio.denominator) /
                Decimal.fromBigInt(ratio.numerator))
            .toDecimal(scaleOnInfinitePrecision: 8);
        // Format the newGet to match the expected decimal places

        emit(state.copyWith(
          giveQuantity: input,
          getQuantity: GetQuantityInput.dirty(formatDecimal(newGet),
              isDivisible: state.getQuantity.isDivisible),
          errorMessage: null,
        ));
        return;
      } else {
        // If quantities are invalid, emit an error and disable lockRatio
        emit(state.copyWith(
          lockRatio: false,
          ratio: null,
          errorMessage: 'Cannot lock ratio: invalid quantities.',
        ));
        return;
      }
    }

    // If lockRatio is not enabled, just update the giveQuantity
    emit(state.copyWith(
      giveQuantity: input,
      errorMessage: null,
    ));
  }

  void _onGiveQuantityBlurred(
    GiveQuantityBlurred event,
    Emitter<FormStateModel> emit,
  ) async {
    final value = state.giveQuantity.value;

    late bool isDivisible;
    late int balance;

    try {
      final asset =
          await assetRepository.getAssetVerbose(assetName: state.giveAsset.value, httpConfig: httpConfig);
      isDivisible = asset.divisible ?? true;
    } catch (e) {
      isDivisible = true;
    }

    try {
      final balance_ = _getBalanceForAsset(state.giveAsset.value);
      balance = balance_?.quantity ?? 0;
    } catch (e) {
      balance = 0;
    }

    final input = GiveQuantityInput.dirty(
      value,
      balance: balance,
      isDivisible: isDivisible,
    );

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
          ? (double.parse(state.getQuantity.value) * SATOSHI_RATE).round()
          : int.parse(state.getQuantity.value));
      final int giveQuantity = (state.giveQuantity.isDivisible
          ? (double.parse(state.giveQuantity.value) * SATOSHI_RATE).round()
          : int.parse(state.giveQuantity.value));

      // Making the compose transaction call
      final composeResponse = await composeTransactionUseCase
          .call<ComposeOrderParams, ComposeOrderResponse>(
        httpConfig: httpConfig,
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

      final composed = composeResponse;
      final virtualSize = VirtualSize(
          composed.signedTxEstimatedSize.virtualSize,
          composed.signedTxEstimatedSize.adjustedVirtualSize);

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
      return await getFeeEstimatesUseCase.call(httpConfig: httpConfig);
    } catch (e) {
      throw FetchFeeEstimatesException(e.toString());
    }
  }

  num _getFeeRate() {
    return switch (state.feeEstimates) {
      Success(data: var feeEstimates) => switch (state.feeOption) {
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

  double? _parseQuantity(String value) {
    try {
      return double.parse(value);
    } catch (e) {
      return null;
    }
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

String formatDecimal(Decimal decimal, {int maxDecimalPlaces = 8}) {
  Decimal rounded = decimal.round(scale: maxDecimalPlaces);

  String fixed = rounded.toStringAsFixed(maxDecimalPlaces);

  fixed = fixed.replaceFirst(RegExp(r'0+$'), ''); // Remove trailing zeros
  fixed = fixed.replaceFirst(
      RegExp(r'\.$'), ''); // Remove trailing decimal point if any

  return fixed;
}
