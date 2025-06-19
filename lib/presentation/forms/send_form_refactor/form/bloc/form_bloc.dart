import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/fee_option.dart' as fee_option;
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import "package:decimal/decimal.dart";
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';

import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';

import "form_event.dart";
import "form_state.dart";

class SendAssetFormBloc extends Bloc<FormEvent, FormModel> {
  final ComposeTransactionUseCase composeTransactionUseCase;
  final ComposeRepository composeRepository;
  final Asset asset;
  final HttpConfig httpConfig;

  SendAssetFormBloc(
      {required this.asset,
      required this.httpConfig,
      ComposeTransactionUseCase? composeTransactionUseCase,
      ComposeRepository? composeRepository,
      required FeeEstimates feeEstimates,
      required MultiAddressBalanceEntry initialAddressBalanceValue})
      : composeTransactionUseCase =
            composeTransactionUseCase ?? GetIt.I<ComposeTransactionUseCase>(),
        composeRepository = composeRepository ?? GetIt.I<ComposeRepository>(),
        super(FormModel(
          feeEstimates: feeEstimates,
          addressBalanceInput:
              AddressBalanceInput.dirty(value: initialAddressBalanceValue),
          destinationInput: const DestinationInput.pure(),
          quantityInput: QuantityInput.pure(
            maxValue:
                Decimal.parse(initialAddressBalanceValue.quantityNormalized),
          ),
          feeOptionInput: FeeOptionInput.pure(),
        )) {
    on<AddressBalanceInputChanged>(_handleAddressBalanceInputChanged);
    on<DestinationInputChanged>(_handleDestinationInputChanged);
    on<QuantityInputChanged>(_handleQuantityInputChanged);
    on<FeeOptionChanged>(_handleFeeOptionChanged);
    on<FormSubmitted>(_handleFormSubmitted);
  }

  _handleAddressBalanceInputChanged(
    AddressBalanceInputChanged event,
    Emitter<FormModel> emit,
  ) {
    final addressBalanceInput = AddressBalanceInput.dirty(value: event.value);

    final maxValue =
        Decimal.parse(addressBalanceInput.value.quantityNormalized);

    final newState = state.copyWith(
      addressBalanceInput: addressBalanceInput,
      quantityInput: QuantityInput.dirty(
        value: state.quantityInput.value,
        maxValue: maxValue,
      ),
    );

    emit(newState);
  }

  _handleDestinationInputChanged(
    DestinationInputChanged event,
    Emitter<FormModel> emit,
  ) {
    final destinationInput = DestinationInput.dirty(value: event.value);

    final newState = state.copyWith(destinationInput: destinationInput);

    emit(newState);
  }

  _handleQuantityInputChanged(
    QuantityInputChanged event,
    Emitter<FormModel> emit,
  ) {
    final quantityInput = QuantityInput.dirty(
        value: event.value, maxValue: state.quantityInput.maxValue);

    final newState = state.copyWith(quantityInput: quantityInput);

    emit(newState);
  }

  _handleFeeOptionChanged(
    FeeOptionChanged event,
    Emitter<FormModel> emit,
  ) {
    final feeOptionInput = FeeOptionInput.dirty(event.value);

    final newState = state.copyWith(feeOptionInput: feeOptionInput);

    emit(newState);
  }

  _handleFormSubmitted(
    FormSubmitted event,
    Emitter<FormModel> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final feeRate = switch (state.feeOptionInput.value) {
        fee_option.Slow() => state.feeEstimates.slow,
        fee_option.Medium() => state.feeEstimates.medium,
        fee_option.Fast() => state.feeEstimates.fast,
        fee_option.Custom(fee: var value) => value
      };

      final quantityNormalized = Decimal.parse(state.quantityInput.value);

      final quantity = asset.divisible ?? false
          ? quantityNormalized * Decimal.fromInt(100000000)
          : quantityNormalized;

      // TODO: validate that address is never empty
      final composeResponse = await composeTransactionUseCase
          .call<ComposeSendParams, ComposeSendResponse>(
        httpConfig: httpConfig,
        feeRate: feeRate,
        source: state.addressBalanceInput.value.address!,
        params: ComposeSendParams(
          source: state.addressBalanceInput.value.address!,
          destination: state.destinationInput.value,
          asset: asset.asset,
          quantity: quantity.toBigInt().toInt(), // TODO: convert to bigint
        ),
        composeFn: composeRepository.composeSendVerbose,
      );

      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        composeResponse: composeResponse,
      ));
    } catch (e) {
      print(e);
      emit(state.copyWith(
          status: FormzSubmissionStatus.failure, error: e.toString()));
    }
  }
}
