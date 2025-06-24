import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/entities/http_config.dart' hide Custom;

enum FeeOptionError { invalid }

class FeeOptionInput extends FormzInput<FeeOption, FeeOptionError> {
  FeeOptionInput.pure() : super.pure(Medium());
  const FeeOptionInput.dirty(super.value) : super.dirty();
  @override
  FeeOptionError? validator(FeeOption value) {
    return switch (value) {
      Custom(fee: var value) => value < 0 ? FeeOptionError.invalid : null,
      _ => null
    };
  }
}

class AtomicSwapSignModel with FormzMixin {
  final AddressV2 address;

  final AtomicSwap atomicSwap;

  final FeeEstimates feeEstimates;
  final FeeOptionInput feeOptionInput;
  final FormzSubmissionStatus submissionStatus;

  final Option<String> error;

  const AtomicSwapSignModel({
    required this.address,
    required this.atomicSwap,
    this.submissionStatus = FormzSubmissionStatus.initial,
    required this.feeEstimates,
    required this.feeOptionInput,
    required this.error,
  });

  @override
  List<FormzInput> get inputs => [];

  AtomicSwapSignModel copyWith({
    AtomicSwap? atomicSwap,
    FeeEstimates? feeEstimates,
    FeeOptionInput? feeOptionInput,
    FormzSubmissionStatus? submissionStatus,
    Option<String>? error,
    AddressV2? address,
  }) {
    return AtomicSwapSignModel(
      address: address ?? this.address,
      atomicSwap: atomicSwap ?? this.atomicSwap,
      feeEstimates: feeEstimates ?? this.feeEstimates,
      feeOptionInput: feeOptionInput ?? this.feeOptionInput,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      error: error ?? this.error,
    );
  }

  String get rateString {
    return '1 ${atomicSwap.assetName} = ${atomicSwap.pricePerUnit.normalizedPretty(precision: 8)} BTC';
  }
}

class SwapBuySignFormModel {
  final int swapIndex;
  final List<AtomicSwapSignModel> atomicSwaps;

  SwapBuySignFormModel({required this.swapIndex, required this.atomicSwaps});

  SwapBuySignFormModel copyWith({
    int? swapIndex,
    List<AtomicSwapSignModel>? atomicSwaps,
  }) {
    return SwapBuySignFormModel(
      swapIndex: swapIndex ?? this.swapIndex,
      atomicSwaps: atomicSwaps ?? this.atomicSwaps,
    );
  }

  AtomicSwapSignModel get current => atomicSwaps[swapIndex];
}

sealed class SwapBuySignFormEvent extends Equatable {
  const SwapBuySignFormEvent();

  @override
  List<Object?> get props => [];
}

class SubmitClicked extends SwapBuySignFormEvent {}

class FeeOptionChanged extends SwapBuySignFormEvent {
  final FeeOption value;
  const FeeOptionChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class SwapBuySignFormBloc
    extends Bloc<SwapBuySignFormEvent, SwapBuySignFormModel> {
  final HttpConfig httpConfig;
  final TransactionService _transactionService;
  final UtxoRepository _utxoRepository;

  SwapBuySignFormBloc({
    required FeeEstimates feeEstimates,
    required List<AtomicSwap> atomicSwaps,
    required AddressV2 address,
    required this.httpConfig,
    TransactionService? transactionService,
    UtxoRepository? utxoRepository,
  })  : _transactionService =
            transactionService ?? GetIt.I<TransactionService>(),
        _utxoRepository = utxoRepository ?? GetIt.I<UtxoRepository>(),
        super(SwapBuySignFormModel(
            swapIndex: 0,
            atomicSwaps: atomicSwaps
                .map((swap) => AtomicSwapSignModel(
                    address: address,
                    atomicSwap: swap,
                    feeEstimates: feeEstimates,
                    feeOptionInput: FeeOptionInput.pure(),
                    error: Option.none()))
                .toList())) {
    on<SubmitClicked>(_handleSubmitClicked);
    on<FeeOptionChanged>(_onFeeOptionChanged);
  }

  _handleSubmitClicked(
    SubmitClicked event,
    Emitter<SwapBuySignFormModel> emit,
  ) {
    HttpConfig config = httpConfig;
    AddressV2 buyerAddress = state.current.address;
    String sellerAddress = state.current.atomicSwap.sellerAddress;
    int assetUtxoValue = state.current.atomicSwap.assetUtxoValue;

    // need to get somewhat fancy here computing tx size, fee, etc and pass
    // in requisite utxo set...


    // final utxoMap = await $(_utxoRepository.getUnattachedUTXOMapForAddressT(
    //    httpConfig: httpConfig,
    //   address: state.address,
    // ));
    //
    // compute change

    String sellerTransactionID = state.current.atomicSwap.assetUtxoId.txid;
    int sellerVout = state.current.atomicSwap.assetUtxoId.vout;
    // get seller transaction

    final currentSwap = state.atomicSwaps[state.swapIndex];
    if (currentSwap.isValid) {}
  }

  void _onFeeOptionChanged(
    FeeOptionChanged event,
    Emitter<SwapBuySignFormModel> emit,
  ) {
    final updatedSwap = state.current
        .copyWith(feeOptionInput: FeeOptionInput.dirty(event.value));

    final updatedSwaps = List<AtomicSwapSignModel>.from(state.atomicSwaps);
    updatedSwaps[state.swapIndex] = updatedSwap;

    emit(state.copyWith(atomicSwaps: updatedSwaps));
  }
}
