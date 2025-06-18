import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/compose_attach_utxo.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import "package:horizon/presentation/forms/base/transaction_form_model_base.dart";
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/forms/asset_balance_form/bloc/asset_balance_form_bloc.dart'
    show AttachedAtomicSwapSell;
import 'package:horizon/domain/entities/address_v2.dart';
export "package:horizon/presentation/forms/base/transaction_form_model_base.dart";

enum AttachQuantityInputError { required, exceedsMax, isZero }

final SUCCESS_TRANSITION_DELAY = const Duration(milliseconds: 400);

class AttachQuantityInput extends FormzInput<String, AttachQuantityInputError> {
  final BigInt maxQuantity;
  final bool divisible;

  const AttachQuantityInput.dirty(
      {required String value,
      required this.maxQuantity,
      required this.divisible})
      : super.dirty(value);

  const AttachQuantityInput.pure(
      {required this.maxQuantity, required this.divisible})
      : super.pure("");

  @override
  AttachQuantityInputError? validator(String value) {
    final val = valueAsBigInt.fold(
        () => AttachQuantityInputError.required,
        (v) => v > maxQuantity
            ? AttachQuantityInputError.exceedsMax
            : v == BigInt.zero
                ? AttachQuantityInputError.isZero
                : null);

    return val;
  }

  Option<BigInt> get valueAsBigInt {
    return Option.tryCatch(() => Decimal.parse(value))
        .map(
          (raw) => divisible ? raw * Decimal.fromInt(100000000) : raw,
        )
        .map(
          (decimal) => decimal.toBigInt(),
        );
  }

  Option<int> get quantity {
    return valueAsBigInt.flatMap(
        (bigInt) => bigInt.isValidInt ? Option.of(bigInt.toInt()) : none());
  }
}

class AssetAttachFormModel
    extends TransactionFormModelBase<ComposeAttachUtxoResponse> {
  final AddressV2 address;
  final String assetName;
  final String assetDescription;
  final String assetBalanceNormalized;
  final int assetBalance;
  final bool assetDivisibility;
  final AttachQuantityInput attachQuantityInput;

  final AttachedAtomicSwapSell? attachedAtomicSwapSell;

  AssetAttachFormModel({
    required super.feeEstimates,
    required super.feeOptionInput,
    required super.submissionStatus,
    super.error,
    required this.address,
    required this.assetName,
    required this.assetDescription,
    required this.assetBalanceNormalized,
    required this.assetBalance,
    required this.assetDivisibility,
    required this.attachQuantityInput,
    this.attachedAtomicSwapSell,
  });

  @override
  List<FormzInput> get inputs => [attachQuantityInput];

  AssetAttachFormModel copyWith({
    FeeEstimates? feeEstimates,
    FeeOptionInput? feeOptionInput,
    String? assetName,
    String? assetBalanceNormalized,
    int? assetBalance,
    bool? assetDivisibility,
    AttachQuantityInput? attachQuantityInput,
    FormzSubmissionStatus? submissionStatus,
    AttachedAtomicSwapSell? attachedAtomicSwapSell,
    String? error,
  }) {
    return AssetAttachFormModel(
        address: address,
        feeEstimates: feeEstimates ?? this.feeEstimates,
        feeOptionInput: feeOptionInput ?? this.feeOptionInput,
        assetName: assetName ?? this.assetName,
        assetDescription: assetDescription ?? this.assetDescription,
        assetBalanceNormalized:
            assetBalanceNormalized ?? this.assetBalanceNormalized,
        assetDivisibility: assetDivisibility ?? this.assetDivisibility,
        assetBalance: assetBalance ?? this.assetBalance,
        attachQuantityInput: attachQuantityInput ?? this.attachQuantityInput,
        submissionStatus: submissionStatus ?? this.submissionStatus,
        error: error ?? this.error,
        attachedAtomicSwapSell:
            attachedAtomicSwapSell ?? this.attachedAtomicSwapSell);
  }

  get submitDisabled => isNotValid || submissionStatus.isInProgress;
}

sealed class AssetAttachFormEvent extends Equatable {
  const AssetAttachFormEvent();

  @override
  List<Object?> get props => [];
}

class AttachQuantityChanged extends AssetAttachFormEvent {
  final String value;
  const AttachQuantityChanged({required this.value});
  @override
  List<Object?> get props => [value];
}

class MaxQuantityClicked extends AssetAttachFormEvent {
  const MaxQuantityClicked();
  @override
  List<Object?> get props => [];
}

class FeeOptionChanged extends AssetAttachFormEvent {
  final FeeOption value;
  const FeeOptionChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class SubmitClicked extends AssetAttachFormEvent {
  const SubmitClicked();
  @override
  List<Object?> get props => [];
}

class AssetAttachFormBloc
    extends Bloc<AssetAttachFormEvent, AssetAttachFormModel> {
  final HttpConfig httpConfig;
  final ComposeTransactionUseCase _composeTransactionUseCase;
  final ComposeRepository _composeRepository;
  final SignAndBroadcastTransactionUseCase _signAndBroadcastTransactionUseCase;
  final BitcoinRepository _bitcoinRepository;

  AssetAttachFormBloc({
    required this.httpConfig,
    required FeeEstimates feeEstimates,
    required String assetName,
    required String assetBalanceNormalized,
    required int assetBalance,
    required bool assetDivisibility,
    required AddressV2 address,
    required String assetDescription,
    ComposeTransactionUseCase? composeTransactionUseCase,
    ComposeRepository? composeRepository,
    SignAndBroadcastTransactionUseCase? signAndBroadcastTransactionUseCase,
    BitcoinRepository? bitcoinRepository,
  })  : _composeTransactionUseCase =
            composeTransactionUseCase ?? GetIt.I<ComposeTransactionUseCase>(),
        _composeRepository = composeRepository ?? GetIt.I<ComposeRepository>(),
        _signAndBroadcastTransactionUseCase =
            signAndBroadcastTransactionUseCase ??
                GetIt.I<SignAndBroadcastTransactionUseCase>(),
        _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        super(AssetAttachFormModel(
          address: address,
          feeEstimates: feeEstimates,
          feeOptionInput: FeeOptionInput.pure(),
          assetName: assetName,
          assetDescription: assetDescription,
          assetBalanceNormalized: assetBalanceNormalized,
          assetBalance: assetBalance,
          assetDivisibility: assetDivisibility,
          attachQuantityInput: AttachQuantityInput.dirty(
              value: assetBalanceNormalized,
              maxQuantity: BigInt.from(assetBalance),
              divisible: assetDivisibility),
          submissionStatus: FormzSubmissionStatus.initial,
        )) {
    on<AttachQuantityChanged>(_handleAttachQuantityInputChanged);
    on<FeeOptionChanged>(_handleFeeOptionChanged);
    on<SubmitClicked>(_handleSubmitClicked);
    on<MaxQuantityClicked>(_handleMaxQuantityClicked);
  }

  void _handleAttachQuantityInputChanged(
    AttachQuantityChanged event,
    Emitter<AssetAttachFormModel> emit,
  ) {
    emit(state.copyWith(
        attachQuantityInput: AttachQuantityInput.dirty(
            value: event.value,
            maxQuantity: BigInt.from(state.assetBalance),
            divisible: state.assetDivisibility)));
  }

  _handleFeeOptionChanged(
    FeeOptionChanged event,
    Emitter<AssetAttachFormModel> emit,
  ) {
    final feeOptionInput = FeeOptionInput.dirty(event.value);

    final newState = state.copyWith(feeOptionInput: feeOptionInput);

    emit(newState);
  }

  _handleMaxQuantityClicked(
    MaxQuantityClicked event,
    Emitter<AssetAttachFormModel> emit,
  ) {
    final attachQuantityInput = AttachQuantityInput.dirty(
      value: state.assetBalanceNormalized,
      maxQuantity: BigInt.from(state.assetBalance),
      divisible: state.assetDivisibility,
    );

    final newState = state.copyWith(attachQuantityInput: attachQuantityInput);

    emit(newState);
  }

  _handleSubmitClicked(
    SubmitClicked event,
    Emitter<AssetAttachFormModel> emit,
  ) async {
    emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));

   final task = TaskEither<String, AttachedAtomicSwapSell>.Do(($) async {
      final quantity = await $(TaskEither.fromOption(
          state.attachQuantityInput.quantity,
          () => "Invariant: Error parsing quantity"));

      final composeResponse = await $(_composeTransactionUseCase
          .callT<ComposeAttachUtxoParams, ComposeAttachUtxoResponse>(
        httpConfig: httpConfig,
        feeRate: state.getSatsPerVByte,
        source: state.address.address,
        params: ComposeAttachUtxoParams(
          address: state.address.address,
          asset: state.assetName,
          quantity: quantity,
        ),
        composeFn: _composeRepository.composeAttachUtxo,
      ));

      final broadcastResponse =
          await $(_signAndBroadcastTransactionUseCase.callT(
        httpConfig: httpConfig,
        source: state.address,
        decryptionStrategy: InMemoryKey(),
        rawtransaction: composeResponse.rawtransaction,
      ));

      // now the problem reduces to "AttachedAtomicSwapSell" variant
      return AttachedAtomicSwapSell(
        asset: composeResponse.params.asset,
        quantity: composeResponse.params.quantity,
        quantityNormalized: composeResponse.params.quantityNormalized,
        utxo: "${broadcastResponse.hash}:0",
        utxoAddress: composeResponse.params.source,
      );
    });

    final result = await task.run();

    result.fold((error) {
      emit(state.copyWith(
          submissionStatus: FormzSubmissionStatus.failure,
          error: error.toString()));
    }, (attachedAtomicSwapSell) async {
      emit(state.copyWith(
          submissionStatus: FormzSubmissionStatus.success));

      await Future.delayed(SUCCESS_TRANSITION_DELAY);

      emit(state.copyWith(
          submissionStatus: FormzSubmissionStatus.success,
          attachedAtomicSwapSell: attachedAtomicSwapSell));
    });
  }
}
