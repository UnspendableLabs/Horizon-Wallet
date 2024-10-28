import 'package:equatable/equatable.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';

enum SellAssetValidationError { empty }

// Extend FormzInput and provide the validation logic
class SellAssetInput extends FormzInput<String, SellAssetValidationError> {
  const SellAssetInput.pure() : super.pure('');
  const SellAssetInput.dirty([String value = '']) : super.dirty(value);

  @override
  SellAssetValidationError? validator(String value) {
    return value.isNotEmpty ? null : SellAssetValidationError.empty;
  }
}

enum BuyAssetValidationError { empty }

class BuyAssetInput extends FormzInput<String, BuyAssetValidationError> {
  const BuyAssetInput.pure() : super.pure('');
  const BuyAssetInput.dirty([String value = '']) : super.dirty(value);

  @override
  BuyAssetValidationError? validator(String value) {
    return value.isNotEmpty ? null : BuyAssetValidationError.empty;
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

enum QuantityValidationError { invalid }

class QuantityInput extends FormzInput<String, QuantityValidationError> {
  const QuantityInput.pure() : super.pure('');
  const QuantityInput.dirty([String value = '']) : super.dirty(value);
  @override
  QuantityValidationError? validator(String value) {
    final quantity = double.tryParse(value);
    return (quantity != null && quantity > 0)
        ? null
        : QuantityValidationError.invalid;
  }
}

// lib/models/remote_data.dart

abstract class RemoteData<T> {
  const RemoteData();
}

class NotAsked<T> extends RemoteData<T> {
  const NotAsked();
}

class Loading<T> extends RemoteData<T> {
  const Loading();
}

class Success<T> extends RemoteData<T> {
  final T data;

  const Success(this.data);
}

class Failure<T> extends RemoteData<T> {
  final String error;

  const Failure(this.error);
}

// events

abstract class FormEvent extends Equatable {
  const FormEvent();

  @override
  List<Object?> get props => [];
}

class LoadSellAssets extends FormEvent {}

class SellAssetChanged extends FormEvent {
  final String sellAssetId;

  const SellAssetChanged(this.sellAssetId);

  @override
  List<Object?> get props => [sellAssetId];
}

class BuyAssetChanged extends FormEvent {
  final String buyAssetId;

  const BuyAssetChanged(this.buyAssetId);

  @override
  List<Object?> get props => [buyAssetId];
}

class QuantityChanged extends FormEvent {
  final String quantity;

  const QuantityChanged(this.quantity);

  @override
  List<Object?> get props => [quantity];
}

class PriceChanged extends FormEvent {
  final String price;

  const PriceChanged(this.price);

  @override
  List<Object?> get props => [price];
}

class FormSubmitted extends FormEvent {}

// state

class FormStateModel extends Equatable {
  final RemoteData<List<Balance>> sellAssets;
  final RemoteData<List<Asset>> buyAssets;
  final SellAssetInput sellAsset;
  final BuyAssetInput buyAsset;
  final QuantityInput quantity;
  final PriceInput price;
  final FormzSubmissionStatus status;
  final bool isSubmitting;
  final String? errorMessage;

  const FormStateModel({
    this.sellAssets = const NotAsked(),
    this.buyAssets = const NotAsked(),
    this.sellAsset = const SellAssetInput.pure(),
    this.buyAsset = const BuyAssetInput.pure(),
    this.quantity = const QuantityInput.pure(),
    this.price = const PriceInput.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.isSubmitting = false,
    this.errorMessage,
  });

  FormStateModel copyWith({
    RemoteData<List<Balance>>? sellAssets,
    RemoteData<List<Asset>>? buyAssets,
    SellAssetInput? sellAsset,
    BuyAssetInput? buyAsset,
    QuantityInput? quantity,
    PriceInput? price,
    FormzSubmissionStatus? status,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return FormStateModel(
      sellAssets: sellAssets ?? this.sellAssets,
      buyAssets: buyAssets ?? this.buyAssets,
      sellAsset: sellAsset ?? this.sellAsset,
      buyAsset: buyAsset ?? this.buyAsset,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      status: status ?? this.status,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        sellAssets,
        buyAssets,
        sellAsset,
        buyAsset,
        quantity,
        price,
        status,
        isSubmitting,
        errorMessage,
      ];
}

class FormBloc extends Bloc<FormEvent, FormStateModel> {
  final BalanceRepository balanceRepository;

  FormBloc({required this.balanceRepository}) : super(const FormStateModel()) {
    on<LoadSellAssets>(_onLoadSellAssets);
  }

  Future<void> _onLoadSellAssets(
    LoadSellAssets event,
    Emitter<FormStateModel> emit,
  ) async {
    emit(state.copyWith(
      sellAssets: const Loading(),
      // status: FormzSubmissionStatus.initial,
      errorMessage: null,
    ));

    try {
      final balances = await balanceRepository.getBalancesForAddress("source");

      emit(state.copyWith(sellAssets: Success(balances)));
    } catch (e) {
      emit(state.copyWith(
        sellAssets: const Failure('Failed to load sell assets'),
        // status: FormzSubmissionStatus.failure,
      ));
    }
  }

  void _onSellAssetChanged(
      SellAssetChanged event, Emitter<FormStateModel> emit) {
    final sellAssetInput = SellAssetInput.dirty(event.sellAssetId);
    emit(state.copyWith(
      sellAsset: sellAssetInput,
      buyAsset: BuyAssetInput.pure(),
      errorMessage: null,
    ));
  }

  void _onBuyAssetChanged(BuyAssetChanged event, Emitter<FormStateModel> emit) {
    final buyAssetInput = BuyAssetInput.dirty(event.buyAssetId);
    emit(state.copyWith(
      buyAsset: buyAssetInput,
      errorMessage: null,
    ));
  }

  void _onQuantityChanged(QuantityChanged event, Emitter<FormStateModel> emit) {
    final quantityInput = QuantityInput.dirty(event.quantity);
    emit(state.copyWith(
      quantity: quantityInput,
      errorMessage: null,
    ));
  }

  void _onPriceChanged(PriceChanged event, Emitter<FormStateModel> emit) {
    final priceInput = PriceInput.dirty(event.price);
    emit(state.copyWith(
      price: priceInput,
      errorMessage: null,
    ));
  }

  Future<void> _onFormSubmitted(
      FormSubmitted event, Emitter<FormStateModel> emit) async {
    final sellAssetInput = SellAssetInput.dirty(state.sellAsset.value);
    final buyAssetInput = BuyAssetInput.dirty(state.buyAsset.value);
    final quantityInput = QuantityInput.dirty(state.quantity.value);
    final priceInput = PriceInput.dirty(state.price.value);

    final validationStatus = Formz.validate([
      sellAssetInput,
      buyAssetInput,
      quantityInput,
      priceInput,
    ]);

    try {
      // TODO: Implement actual form submission logic, e.g., API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      emit(state.copyWith(
        // submissionStatus: FormzSubmissionStatus.success,
        isSubmitting: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        // submissionStatus: FormzSubmissionStatus.failure,
        isSubmitting: false,
        errorMessage: 'Form submission failed',
      ));
    }
  }
}
