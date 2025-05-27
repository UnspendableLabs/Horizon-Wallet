import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import "package:horizon/presentation/forms/base/transaction_form_model_base.dart";
import 'package:horizon/domain/entities/compose_attach_utxo.dart';

enum AttachQuantityInputError { required, exceedsMax, isZero }

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
}

class AssetAttachFormModel
    extends TransactionFormModelBase<ComposeAttachUtxoResponse> {
  final String assetName;
  final String assetBalanceNormalized;
  final int assetBalance;
  final bool assetDivisibility;

  final AttachQuantityInput attachQuantityInput;

  AssetAttachFormModel({
    required super.feeEstimates,
    required super.feeOptionInput,
    required super.status,
    required this.assetName,
    required this.assetBalanceNormalized,
    required this.assetBalance,
    required this.assetDivisibility,
    required this.attachQuantityInput,
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
    FormzSubmissionStatus? status,
  }) {
    return AssetAttachFormModel(
      feeEstimates: feeEstimates ?? this.feeEstimates,
      feeOptionInput: feeOptionInput ?? this.feeOptionInput,
      assetName: assetName ?? this.assetName,
      assetBalanceNormalized:
          assetBalanceNormalized ?? this.assetBalanceNormalized,
      assetDivisibility: assetDivisibility ?? this.assetDivisibility,
      assetBalance: assetBalance ?? this.assetBalance,
      attachQuantityInput: attachQuantityInput ?? this.attachQuantityInput,
      status: status ?? this.status,
    );
  }

  get submitDisabled => isNotValid || status.isInProgress;
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
  AssetAttachFormBloc({
    required FeeEstimates feeEstimates,
    required String assetName,
    required String assetBalanceNormalized,
    required int assetBalance,
    required bool assetDivisibility,
  }) : super(AssetAttachFormModel(
          feeEstimates: feeEstimates,
          feeOptionInput: FeeOptionInput.pure(),
          assetName: assetName,
          assetBalanceNormalized: assetBalanceNormalized,
          assetBalance: assetBalance,
          assetDivisibility: assetDivisibility,
          attachQuantityInput: AttachQuantityInput.dirty(
              value: assetBalanceNormalized,
              maxQuantity: BigInt.from(assetBalance),
              divisible: assetDivisibility),
          status: FormzSubmissionStatus.initial,
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
  ) {}
}
