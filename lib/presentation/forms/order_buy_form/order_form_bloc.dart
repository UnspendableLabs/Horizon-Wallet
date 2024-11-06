import 'package:equatable/equatable.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';

enum GiveAssetValidationError { empty }

class GiveAssetInput extends FormzInput<String, GiveAssetValidationError> {
  const GiveAssetInput.pure() : super.pure('');
  const GiveAssetInput.dirty([String value = '']) : super.dirty(value);

  @override
  GiveAssetValidationError? validator(String value) {
    return value.isNotEmpty ? null : GiveAssetValidationError.empty;
  }
}

enum GetAssetValidationError { empty }

class GetAssetInput extends FormzInput<String, GetAssetValidationError> {
  const GetAssetInput.pure() : super.pure('');
  const GetAssetInput.dirty([String value = '']) : super.dirty(value);

  @override
  GetAssetValidationError? validator(String value) {
    return value.isNotEmpty ? null : GetAssetValidationError.empty;
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
    return (quantity != null && quantity > 0) ? null : QuantityValidationError.invalid;
  }
}

// Events

abstract class FormEvent extends Equatable {
  const FormEvent();

  @override
  List<Object?> get props => [];
}

class LoadGiveAssets extends FormEvent {}

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

// State

class FormStateModel extends Equatable {
  final RemoteData<List<Balance>> giveAssets;
  final RemoteData<List<Asset>> getAssets;
  final GiveAssetInput giveAsset;
  final GetAssetInput getAsset;
  final QuantityInput quantity;
  final PriceInput price;
  final FormzSubmissionStatus submissionStatus;
  final String? errorMessage;

  const FormStateModel({
    required this.giveAssets,
    required this.getAssets,
    this.giveAsset = const GiveAssetInput.pure(),
    this.getAsset = const GetAssetInput.pure(),
    this.quantity = const QuantityInput.pure(),
    this.price = const PriceInput.pure(),
    this.submissionStatus = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  FormStateModel copyWith({
    RemoteData<List<Balance>>? giveAssets,
    RemoteData<List<Asset>>? getAssets,
    GiveAssetInput? giveAsset,
    GetAssetInput? getAsset,
    QuantityInput? quantity,
    PriceInput? price,
    FormzSubmissionStatus? submissionStatus,
    String? errorMessage,
  }) {
    return FormStateModel(
      giveAssets: giveAssets ?? this.giveAssets,
      getAssets: getAssets ?? this.getAssets,
      giveAsset: giveAsset ?? this.giveAsset,
      getAsset: getAsset ?? this.getAsset,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        giveAssets,
        getAssets,
        giveAsset,
        getAsset,
        quantity,
        price,
        submissionStatus,
        errorMessage,
      ];
}

class OrderBuyFormBloc extends Bloc<FormEvent, FormStateModel> {
  final BalanceRepository balanceRepository;
  final currentAddress;

  OrderBuyFormBloc({required this.balanceRepository, required this.currentAddress})
      : super(FormStateModel(
          giveAssets: NotAsked(),
          getAssets: NotAsked(),
        )) {
    on<LoadGiveAssets>(_onLoadGiveAssets);
    on<GiveAssetChanged>(_onGiveAssetChanged);
    on<GetAssetChanged>(_onGetAssetChanged);
    on<QuantityChanged>(_onQuantityChanged);
    on<PriceChanged>(_onPriceChanged);
    on<FormSubmitted>(_onFormSubmitted);
  }

  Future<void> _onLoadGiveAssets(
    LoadGiveAssets event,
    Emitter<FormStateModel> emit,
  ) async {
    emit(state.copyWith(giveAssets: Loading(), errorMessage: null));

    try {
      final balances = await balanceRepository.getBalancesForAddress(currentAddress);
      emit(state.copyWith(giveAssets: Success(balances)));
    } catch (e) {
      emit(state.copyWith(
        giveAssets: Failure('Failed to load give assets'),
      ));
    }
  }

  void _onGiveAssetChanged(
      GiveAssetChanged event, Emitter<FormStateModel> emit) {
    final giveAssetInput = GiveAssetInput.dirty(event.giveAssetId);
    emit(state.copyWith(
      giveAsset: giveAssetInput,
      getAsset: GetAssetInput.pure(),
      errorMessage: null,
    ));
  }

  void _onGetAssetChanged(GetAssetChanged event, Emitter<FormStateModel> emit) {
    final getAssetInput = GetAssetInput.dirty(event.getAssetId);
    emit(state.copyWith(getAsset: getAssetInput, errorMessage: null));
  }

  void _onQuantityChanged(QuantityChanged event, Emitter<FormStateModel> emit) {
    final quantityInput = QuantityInput.dirty(event.quantity);
    emit(state.copyWith(quantity: quantityInput, errorMessage: null));
  }

  void _onPriceChanged(PriceChanged event, Emitter<FormStateModel> emit) {
    final priceInput = PriceInput.dirty(event.price);
    emit(state.copyWith(price: priceInput, errorMessage: null));
  }

  Future<void> _onFormSubmitted(
      FormSubmitted event, Emitter<FormStateModel> emit) async {
    emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      emit(state.copyWith(submissionStatus: FormzSubmissionStatus.success));
    } catch (e) {
      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.failure,
        errorMessage: 'Form submission failed',
      ));
    }
  }
}

