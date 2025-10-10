import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/balance_v2.dart';

abstract class SendEntryFormEvent {
  const SendEntryFormEvent();
}

class AddressBalanceInputChanged extends SendEntryFormEvent {
  final AssetBalanceSummary value;
  const AddressBalanceInputChanged(this.value);
}

class DestinationInputChanged extends SendEntryFormEvent {
  final String value;
  const DestinationInputChanged(this.value);
}

class QuantityInputChanged extends SendEntryFormEvent {
  final String value;
  const QuantityInputChanged(this.value);
}

class MemoInputChanged extends SendEntryFormEvent {
  final String value;
  const MemoInputChanged(this.value);
}

class MaxAmountSelected extends SendEntryFormEvent {
  const MaxAmountSelected();
}

class SendEntryFormBloc extends Bloc<SendEntryFormEvent, SendEntryFormModel> {
  SendEntryFormBloc(
      {AssetBalanceSummary? initialBalance,
      required String initialQuantity,
      required String initialDestination,
      required String initialMemo})
      : super(SendEntryFormModel(
          balanceSelectorInput: initialBalance != null
              ? BalanceSelectorInput.dirty(value: initialBalance)
              : const BalanceSelectorInput.pure(),
          destinationInput: DestinationInput.dirty(value: initialDestination),
          quantityInput: QuantityInput.dirty(
              value: initialQuantity,
              maxQuantity:
                  initialBalance?.balance.total.quantity ?? BigInt.zero,
              divisible: initialBalance?.balance.total.divisible ?? false),
          memoInput: MemoInput.dirty(value: initialMemo),
        )) {
    on<AddressBalanceInputChanged>(_onAddressBalanceInputChanged);
    on<DestinationInputChanged>(_onDestinationInputChanged);
    on<QuantityInputChanged>(_onQuantityInputChanged);
    on<MemoInputChanged>(_onMemoInputChanged);
    on<MaxAmountSelected>(_onMaxAmountSelected);
  }

  void _onAddressBalanceInputChanged(
      AddressBalanceInputChanged event, Emitter<SendEntryFormModel> emit) {
    emit(state.copyWith(
        balanceSelectorInput: BalanceSelectorInput.dirty(value: event.value)));
  }

  void _onDestinationInputChanged(
      DestinationInputChanged event, Emitter<SendEntryFormModel> emit) {
    emit(state.copyWith(
        destinationInput: DestinationInput.dirty(value: event.value)));
  }

  void _onQuantityInputChanged(
      QuantityInputChanged event, Emitter<SendEntryFormModel> emit) {
    emit(state.copyWith(
        quantityInput: QuantityInput.dirty(
            value: event.value,
            maxQuantity: BigInt.from(state.assetBalance),
            divisible: state.assetIsDivisible)));
  }

  void _onMaxAmountSelected(
      MaxAmountSelected event, Emitter<SendEntryFormModel> emit) {
    emit(state.copyWith(
        quantityInput: QuantityInput.dirty(
            value: state.assetQuantityNormalized,
            maxQuantity: BigInt.from(state.assetBalance),
            divisible: state.assetIsDivisible)));
  }

  void _onMemoInputChanged(
      MemoInputChanged event, Emitter<SendEntryFormModel> emit) {
    emit(state.copyWith(memoInput: MemoInput.dirty(value: event.value)));
  }
}

enum SendEntryFormInputError {
  destinationRequired,
  quantityRequired,
  balanceRequired,
  quantityExceedsMax,
  quantityIsZero,
}

class DestinationInput extends FormzInput<String, SendEntryFormInputError> {
  const DestinationInput.pure() : super.pure("");
  const DestinationInput.dirty({required String value}) : super.dirty(value);

  @override
  SendEntryFormInputError? validator(String? value) {
    if (value == null || value.isEmpty) {
      return SendEntryFormInputError.destinationRequired;
    }
    // TODO: check is valid address
    return null;
  }
}

class QuantityInput extends FormzInput<String, SendEntryFormInputError> {
  final BigInt maxQuantity;
  final bool divisible;

  const QuantityInput.dirty(
      {required String value,
      required this.maxQuantity,
      required this.divisible})
      : super.dirty(value);

  const QuantityInput.pure({required this.maxQuantity, required this.divisible})
      : super.pure("");

  @override
  SendEntryFormInputError? validator(String value) {
    final val = valueAsBigInt.fold(
        () => SendEntryFormInputError.quantityRequired,
        (v) => v > maxQuantity
            ? SendEntryFormInputError.quantityExceedsMax
            : v == BigInt.zero
                ? SendEntryFormInputError.quantityIsZero
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

class BalanceSelectorInput
    extends FormzInput<AssetBalanceSummary?, SendEntryFormInputError> {
  const BalanceSelectorInput.dirty({required AssetBalanceSummary value})
      : super.dirty(value);

  const BalanceSelectorInput.pure() : super.pure(null);

  @override
  SendEntryFormInputError? validator(AssetBalanceSummary? value) {
    if (value == null) {
      return SendEntryFormInputError.balanceRequired;
    }
    return null;
  }
}

class MemoInput extends FormzInput<String, SendEntryFormInputError> {
  const MemoInput.pure() : super.pure("");
  const MemoInput.dirty({required String value}) : super.dirty(value);

  @override
  SendEntryFormInputError? validator(String? value) {
    return null;
  }
}

class SendEntryFormModel with FormzMixin {
  final DestinationInput destinationInput;
  final QuantityInput quantityInput;
  final BalanceSelectorInput balanceSelectorInput;
  final MemoInput memoInput;

  SendEntryFormModel(
      {required this.destinationInput,
      required this.quantityInput,
      required this.balanceSelectorInput,
      required this.memoInput});

  @override
  List<FormzInput> get inputs =>
      [destinationInput, quantityInput, balanceSelectorInput, memoInput];

  SendEntryFormModel copyWith({
    DestinationInput? destinationInput,
    QuantityInput? quantityInput,
    BalanceSelectorInput? balanceSelectorInput,
    MemoInput? memoInput,
  }) {
    return SendEntryFormModel(
      destinationInput: destinationInput ?? this.destinationInput,
      quantityInput: quantityInput ?? this.quantityInput,
      balanceSelectorInput: balanceSelectorInput ?? this.balanceSelectorInput,
      memoInput: memoInput ?? this.memoInput,
    );
  }

  bool get assetIsDivisible =>
      balanceSelectorInput.value?.balance.total.divisible ?? false;

  String get assetQuantityNormalized =>
      balanceSelectorInput.value?.balance.total.normalized() ?? "";

  int get assetBalance =>
      balanceSelectorInput.value?.balance.total.quantity.toInt() ?? 0;

  @override
  String toString() {
    return "SendEntryFormModel(destinationInput: $destinationInput, quantityInput: $quantityInput, balanceSelectorInput: $balanceSelectorInput, memoInput: $memoInput)";
  }
}
