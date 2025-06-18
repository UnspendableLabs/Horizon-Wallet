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
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/atomic_swap/on_chain_payment.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/atomic_swap_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import "package:horizon/presentation/forms/base/transaction_form_model_base.dart";
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/forms/asset_balance_form/bloc/asset_balance_form_bloc.dart'
    show AttachedAtomicSwapSell;
import 'package:horizon/domain/entities/address_v2.dart';
export "package:horizon/presentation/forms/base/transaction_form_model_base.dart";
import 'package:rxdart/rxdart.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

class SwapCreateListingFormModel
    extends TransactionFormModelBase<ComposeAttachUtxoResponse> {
  final AddressV2 address;
  final String giveAsset;
  final int giveQuantity;
  final String giveQuantityNormalized;
  final BigInt btcPrice;
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
      int? giveQuantity,
      RemoteData<OnChainPayment>? onChainPayment,
      Option<bool> showSignPsbtModal = const None()}) {
    return SwapCreateListingFormModel(
      address: address,
      giveQuantity: giveQuantity ?? this.giveQuantity,
      btcPrice: btcPrice ?? this.btcPrice,
      feeEstimates: feeEstimates ?? this.feeEstimates,
      feeOptionInput: feeOptionInput ?? this.feeOptionInput,
      giveAsset: giveAsset ?? this.giveAsset,
      giveQuantityNormalized:
          giveAssetQuantityNormalized ?? this.giveQuantityNormalized,
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

  String get btcPriceNormalized {
    return (btcPrice.toInt() / 100000000).toStringAsFixed(8);
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
  final ComposeTransactionUseCase _composeTransactionUseCase;
  final ComposeRepository _composeRepository;
  final SignAndBroadcastTransactionUseCase _signAndBroadcastTransactionUseCase;
  final BitcoinRepository _bitcoinRepository;
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
    ComposeTransactionUseCase? composeTransactionUseCase,
    ComposeRepository? composeRepository,
    SignAndBroadcastTransactionUseCase? signAndBroadcastTransactionUseCase,
    BitcoinRepository? bitcoinRepository,
    AtomicSwapRepository? atomicSwapRepository,
    UtxoRepository? utxoRepository,
  })  : _composeTransactionUseCase =
            composeTransactionUseCase ?? GetIt.I<ComposeTransactionUseCase>(),
        _composeRepository = composeRepository ?? GetIt.I<ComposeRepository>(),
        _signAndBroadcastTransactionUseCase =
            signAndBroadcastTransactionUseCase ??
                GetIt.I<SignAndBroadcastTransactionUseCase>(),
        _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        _atomicSwapRepository =
            atomicSwapRepository ?? GetIt.I<AtomicSwapRepository>(),
        _utxoRepository = utxoRepository ?? GetIt.I<UtxoRepository>(),
        super(SwapCreateListingFormModel(
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

    on<SignatureCompleted>((event, emit) {
      emit(state.copyWith(
        showSignPsbtModal: const Option.of(false),
        submissionStatus: FormzSubmissionStatus.success,
      ));

      emit(state.copyWith(
        showSignPsbtModal: const Option.of(false),
        submissionStatus: FormzSubmissionStatus.initial,
      ));
    });
    add(const OnChainPaymentRequested());
  }

  _handleFeeOptionChanged(
    FeeOptionChanged event,
    Emitter<SwapCreateListingFormModel> emit,
  ) {
    final feeOptionInput = FeeOptionInput.dirty(event.value);

    final newState = state.copyWith(feeOptionInput: feeOptionInput);

    emit(newState);

    add(OnChainPaymentRequested());
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
        showSignPsbtModal: Option.of(true)));
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
