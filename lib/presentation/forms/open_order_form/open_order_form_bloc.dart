import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:rxdart/rxdart.dart';

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

enum GiveQuantityValidationError { invalid, exceedsBalance }

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
      return GiveQuantityValidationError.invalid;
    }

    final quantity = isDivisible
        ? (double.tryParse(value)! * 100000000)
        : int.tryParse(value);

    if (quantity == null || quantity <= 0) {
      print("quantity was null orless than 0");
      return GiveQuantityValidationError.invalid;
    }
    if (balance != null && quantity > balance!) {
      print("balance was null");
      return GiveQuantityValidationError.exceedsBalance;
    }
    return null;
  }
}

enum GetQuantityValidationError { invalid }

class GetQuantityInput extends FormzInput<String, GetQuantityValidationError> {
  final bool isDivisible;

  const GetQuantityInput.pure({this.isDivisible = false}) : super.pure('');

  const GetQuantityInput.dirty(String value, {this.isDivisible = false})
      : super.dirty(value);

  @override
  GetQuantityValidationError? validator(String value) {
    if (value.isEmpty) return GetQuantityValidationError.invalid;

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

class InitializeForm extends FormEvent {
  final String? initialGiveAsset;
  final int? initialGiveQuantity;

  const InitializeForm({this.initialGiveAsset, this.initialGiveQuantity});

  @override
  List<Object?> get props => [initialGiveAsset, initialGiveQuantity];
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

class FormSubmitted extends FormEvent {}

// State

class FormStateModel extends Equatable {
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
      errorMessage: errorMessage,
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
      ];
}

class OpenOrderFormBloc extends Bloc<FormEvent, FormStateModel> {
  final BalanceRepository balanceRepository;
  final AssetRepository assetRepository;
  final currentAddress;

  OpenOrderFormBloc({
    required this.assetRepository,
    required this.balanceRepository,
    required this.currentAddress,
    String? initialGiveAsset,
    int? initialGiveQuantity,
  }) : super(FormStateModel(
            giveAssets: NotAsked(),
            getAssets: NotAsked(),
            getAssetValidationStatus: NotAsked())) {
    on<LoadGiveAssets>(_onLoadGiveAssets);
    on<GiveAssetChanged>(_onGiveAssetChanged);
    on<GetAssetChanged>(_onGetAssetChanged,
        transformer: debounce(const Duration(milliseconds: 300)));
    on<GetQuantityChanged>(_onGetQuantityChanged);
    on<GiveQuantityChanged>(_onGiveQuantityChanged);

    on<FormSubmitted>(_onFormSubmitted);
    on<InitializeForm>(_onInitializeForm);
  }
  Future<void> _onInitializeForm(
    InitializeForm event,
    Emitter<FormStateModel> emit,
  ) async {
    emit(state.copyWith(giveAssets: Loading()));

    try {
      final balances =
          await balanceRepository.getBalancesForAddress(currentAddress);
      emit(state.copyWith(giveAssets: Success(balances)));

      print("initialGiveAsset: ${event.initialGiveAsset}");
      print("initialGiveQuantity: ${event.initialGiveQuantity}");

      if (event.initialGiveAsset != null) {

        

        String initialGiveAsset = event.initialGiveAsset!;

        final balanceForAsset = balances.firstWhereOrNull(
          (balance) => balance.asset == initialGiveAsset,
        );

        if (balanceForAsset == null) {
          // Case: No balance for the initial asset
          emit(state.copyWith(
            giveAsset: GiveAssetInput.dirty(initialGiveAsset),
            giveAssets: Success(balances),
            errorMessage:
                'No balance available for the initial asset $initialGiveAsset',
          ));
          return;
        }

        if (event.initialGiveQuantity != null) {
          int initialGiveQuantity = event.initialGiveQuantity!;

          final initialGiveQuantityNormalized =
              balanceForAsset.assetInfo.divisible
                  ? (initialGiveQuantity / 100000000)
                  : initialGiveQuantity;

          if (initialGiveQuantity > balanceForAsset.quantity) {
            // Case: Insufficient balance
            emit(state.copyWith(
              giveAsset: GiveAssetInput.dirty(initialGiveAsset),
              giveAssets: Success(balances),
              giveQuantity: GiveQuantityInput.dirty(
                initialGiveQuantityNormalized.toString(),
                balance: balanceForAsset.quantity,
                isDivisible: balanceForAsset.assetInfo.divisible,
              ),
              errorMessage:
                  'Insufficient balance for the initial quantity of $initialGiveQuantity',
            ));
          } else {
            // Case: Valid initial balance and quantity
            emit(state.copyWith(
              giveAsset: GiveAssetInput.dirty(initialGiveAsset),
              giveAssets: Success(balances),
              giveQuantity: GiveQuantityInput.dirty(
                initialGiveQuantityNormalized.toString(),
                balance: balanceForAsset.quantity,
                isDivisible: balanceForAsset.assetInfo.divisible,
              ),
            ));
          }
        }
      } else {
        emit(state.copyWith(giveAssets: Success(balances)));
      }
    } catch (e) {
      emit(state.copyWith(
        giveAssets: Failure('Failed to load give assets: ${e.toString()}'),
      ));
    }
  }

  Future<void> _onLoadGiveAssets(
    LoadGiveAssets event,
    Emitter<FormStateModel> emit,
  ) async {
    emit(state.copyWith(giveAssets: Loading(), errorMessage: null));

    try {
      final balances_ =
          await balanceRepository.getBalancesForAddress(currentAddress);

      final balances =
          balances_.where((balance) => balance.asset != "BTC").toList();

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
      giveQuantity: const GiveQuantityInput.pure(),
      giveAsset: giveAssetInput,
      getAsset: const GetAssetInput.pure(),
      errorMessage: null,
    ));
  }

  void _onGetAssetChanged(
      GetAssetChanged event, Emitter<FormStateModel> emit) async {
    // todo change to modal
    final getAssetInput = GetAssetInput.dirty(event.getAssetId);
    emit(state.copyWith(
      getQuantity: const GetQuantityInput.pure(),
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
    final isDivisible = state.getAssetValidationStatus is Success<Asset> &&
        (state.getAssetValidationStatus as Success<Asset>).data.divisible ==
            true;

    final input = GetQuantityInput.dirty(event.value, isDivisible: isDivisible);
    emit(state.copyWith(getQuantity: input, errorMessage: null));
  }

  void _onGiveQuantityChanged(
      GiveQuantityChanged event, Emitter<FormStateModel> emit) {
    final balance = _getBalanceForAsset(state.giveAsset.value);

    final input = GiveQuantityInput.dirty(event.value,
        balance: balance?.quantity,
        isDivisible: balance?.assetInfo.divisible ?? false);

    emit(state.copyWith(giveQuantity: input, errorMessage: null));
  }

  Balance? _getBalanceForAsset(String assetId) {
    return switch (state.giveAssets) {
      Success(data: var data) =>
        data.firstWhere((balance) => balance.asset == assetId),
      _ => null,
    };
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

EventTransformer<T> debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}
