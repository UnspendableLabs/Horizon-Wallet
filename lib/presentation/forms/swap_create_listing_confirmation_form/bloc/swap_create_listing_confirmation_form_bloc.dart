import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/compose_attach_utxo.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/atomic_swap/on_chain_payment.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/atomic_swap_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import "package:horizon/presentation/forms/base/transaction_form_model_base.dart";
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';

import 'package:horizon/presentation/screens/swap/view/flows/atomic_swap_sell/atomic_swap_sell_flow.dart'
    show AttachedAtomicSwapSell;
import 'package:horizon/domain/entities/address_v2.dart';
export "package:horizon/presentation/forms/base/transaction_form_model_base.dart";
import 'package:rxdart/rxdart.dart';

class SwapCreateListingFormModel
    extends TransactionFormModelBase<ComposeAttachUtxoResponse> {
  final AddressV2 address;
  final String giveAsset;
  final int giveQuantity;
  final String giveQuantityNormalized;

  final BigInt btcPrice;
  final BigInt royaltyPrice;
  final bool showSignPsbtModal;

  final RemoteData<OnChainPayment> onChainPayment;

  SwapCreateListingFormModel(
      {required super.feeEstimates,
      required this.showSignPsbtModal,
      required super.feeOptionInput,
      required super.submissionStatus,
      super.error,
      required this.address,
      required this.giveAsset,
      required this.giveQuantity,
      required this.giveQuantityNormalized,
      required this.btcPrice,
      required this.royaltyPrice,
      required this.onChainPayment});

  @override
  List<FormzInput> get inputs => [feeOptionInput];

  SwapCreateListingFormModel copyWith(
      {FeeEstimates? feeEstimates,
      FeeOptionInput? feeOptionInput,
      String? giveAsset,
      String? giveAssetQuantityNormalized,
      int? assetBalance,
      FormzSubmissionStatus? submissionStatus,
      AttachedAtomicSwapSell? attachedAtomicSwapSell,
      String? error,
      BigInt? btcPrice,
      BigInt? royaltyPrice,
      int? giveQuantity,
      RemoteData<OnChainPayment>? onChainPayment,
      Option<bool> showSignPsbtModal = const None()}) {
    return SwapCreateListingFormModel(
      address: address,
      giveQuantity: giveQuantity ?? this.giveQuantity,
      btcPrice: btcPrice ?? this.btcPrice,
      royaltyPrice: royaltyPrice ?? this.royaltyPrice,
      feeEstimates: feeEstimates ?? this.feeEstimates,
      feeOptionInput: feeOptionInput ?? this.feeOptionInput,
      giveAsset: giveAsset ?? this.giveAsset,
      giveQuantityNormalized:
          giveAssetQuantityNormalized ?? giveQuantityNormalized,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      error: error ?? this.error,
      onChainPayment: onChainPayment ?? this.onChainPayment,
      showSignPsbtModal:
          showSignPsbtModal.getOrElse(() => this.showSignPsbtModal),
    );
  }

  get submitDisabled => isNotValid || submissionStatus.isInProgress;

  String get rateString {
    return [
      "1",
      giveAsset,
      "=",
      btcPrice.toInt() / giveQuantity / 100000000,
      "BTC"
    ].join(" ");
  }

  BigInt get totalRecive => btcPrice - royaltyPrice;

  String get btcPriceNormalized {
    return (Decimal.fromBigInt(btcPrice) / Decimal.fromInt(100000000))
        .toDecimal()
        .toStringAsFixed(8);
  }

  String get totalReceiveNormalized {
    return (Decimal.fromBigInt(totalRecive) / Decimal.fromInt(100000000))
        .toDecimal()
        .toStringAsFixed(8);
  }

  String get totalRoyaltyNormalized {
    return (Decimal.fromBigInt(royaltyPrice) / Decimal.fromInt(100000000))
        .toDecimal()
        .toStringAsFixed(8);
  }

  // const totalPrice = swaps.reduce((sum, swap) => sum + (BigInt(swap?.price || 0)), BigInt(0));
  // const expectedRoyaltyAmount =
  //     (totalPrice / (BigInt(100) - BigInt(royaltyInfo.royalty) / BigInt(100))) *
  //     (BigInt(royaltyInfo.royalty) / BigInt(100));
  //
  int get royaltyPercentage {
    return (Decimal.fromInt(100) *
            Decimal.fromBigInt(royaltyPrice) /
            Decimal.fromBigInt(btcPrice))
        .floor()
        .toInt();
  }
}

sealed class SwapCreateListingFormEvent extends Equatable {
  const SwapCreateListingFormEvent();

  @override
  List<Object?> get props => [];
}

class FeeOptionChanged extends SwapCreateListingFormEvent {
  final FeeOption value;
  const FeeOptionChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class OnChainPaymentRequested extends SwapCreateListingFormEvent {
  const OnChainPaymentRequested();
  @override
  List<Object?> get props => [];
}

class SubmitClicked extends SwapCreateListingFormEvent {
  const SubmitClicked();
  @override
  List<Object?> get props => [];
}

class CloseSignPsbtModalClicked extends SwapCreateListingFormEvent {
  const CloseSignPsbtModalClicked();
  @override
  List<Object?> get props => [];
}

class SignatureCompleted extends SwapCreateListingFormEvent {
  final String signedPsbtHex;
  const SignatureCompleted({required this.signedPsbtHex});
  @override
  List<Object?> get props => [];
}

class SwapCreateListingFormBloc
    extends Bloc<SwapCreateListingFormEvent, SwapCreateListingFormModel> {
  final HttpConfig httpConfig;
  final AtomicSwapRepository _atomicSwapRepository;
  final UtxoRepository _utxoRepository;

  SwapCreateListingFormBloc({
    required this.httpConfig,
    required FeeEstimates feeEstimates,
    required AddressV2 address,
    required String giveAsset,
    required int giveQuantity,
    required String giveQuantityNormalized,
    required BigInt btcPrice,
    required BigInt royaltyPrice,
    ComposeTransactionUseCase? composeTransactionUseCase,
    ComposeRepository? composeRepository,
    SignAndBroadcastTransactionUseCase? signAndBroadcastTransactionUseCase,
    BitcoinRepository? bitcoinRepository,
    AtomicSwapRepository? atomicSwapRepository,
    UtxoRepository? utxoRepository,
  })  : _atomicSwapRepository =
            atomicSwapRepository ?? GetIt.I<AtomicSwapRepository>(),
        _utxoRepository = utxoRepository ?? GetIt.I<UtxoRepository>(),
        super(SwapCreateListingFormModel(
          royaltyPrice: royaltyPrice,
          feeEstimates: feeEstimates,
          address: address,
          showSignPsbtModal: false,
          feeOptionInput: FeeOptionInput.pure(),
          giveAsset: giveAsset,
          giveQuantity: giveQuantity,
          giveQuantityNormalized: giveQuantityNormalized,
          btcPrice: btcPrice,
          submissionStatus: FormzSubmissionStatus.initial,
          onChainPayment: const Initial<OnChainPayment>(),
        )) {
    on<FeeOptionChanged>(_handleFeeOptionChanged);
    on<OnChainPaymentRequested>(_handleFeeOptionChangedCallback,
        transformer: debounce<OnChainPaymentRequested>(
          const Duration(milliseconds: 300),
        ));
    on<SubmitClicked>(_handleSubmitClicked);
    on<CloseSignPsbtModalClicked>(_handleCloseSignPsbtModalClicked);

    add(const OnChainPaymentRequested());
  }

  _handleFeeOptionChanged(
    FeeOptionChanged event,
    Emitter<SwapCreateListingFormModel> emit,
  ) {
    final feeOptionInput = FeeOptionInput.dirty(event.value);

    final newState = state.copyWith(feeOptionInput: feeOptionInput);

    emit(newState);

    add(const OnChainPaymentRequested());
  }

  _handleFeeOptionChangedCallback(
    OnChainPaymentRequested event,
    Emitter<SwapCreateListingFormModel> emit,
  ) async {
    emit(state.copyWith(onChainPayment: const Loading<OnChainPayment>()));

    final task = TaskEither<String, OnChainPayment>.Do(($) async {
      final utxoMap = await $(_utxoRepository.getUnattachedUTXOMapForAddressT(
        httpConfig: httpConfig,
        address: state.address,
      ));

      final onChainPayment = await $(
          _atomicSwapRepository.createOnChainPaymentT(
              httpConfig: httpConfig,
              address: state.address.address,
              utxoSetIds: utxoMap.keys.toList(),
              satsPerVbyte: state.getSatsPerVByte));

      return onChainPayment;
    });

    final result = await task.run();

    result.fold(
      (l) {
        emit(state.copyWith(
          onChainPayment: Failure(l),
        ));
      },
      (r) {
        emit(state.copyWith(
          onChainPayment: Success<OnChainPayment>(r),
        ));
      },
    );
  }

  _handleSubmitClicked(
    SubmitClicked event,
    Emitter<SwapCreateListingFormModel> emit,
  ) async {

    emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.inProgress,
        showSignPsbtModal: const Option.of(true)));
  }

  void _handleCloseSignPsbtModalClicked(
    CloseSignPsbtModalClicked event,
    Emitter<SwapCreateListingFormModel> emit,
  ) {
    emit(state.copyWith(
      showSignPsbtModal: const Option.of(false),
      submissionStatus: FormzSubmissionStatus.initial,
    ));
  }
}

EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) => events
      .debounceTime(duration) // wait until the stream is quiet
      .switchMap(mapper); // then run the handler once
}
