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

class SwapCreateListingFormModel
    extends TransactionFormModelBase<ComposeAttachUtxoResponse> {
  final AddressV2 address;
  final String giveAsset;
  final int giveQuantity;
  final String giveQuantityNormalized;
  final BigInt btcPrice;

  SwapCreateListingFormModel(
      {required super.feeEstimates,
      required super.feeOptionInput,
      required super.submissionStatus,
      super.error,
      required this.address,
      required this.giveAsset,
      required this.giveQuantity,
      required this.giveQuantityNormalized,
      required this.btcPrice});

  @override
  List<FormzInput> get inputs => [feeOptionInput];

  SwapCreateListingFormModel copyWith({
    FeeEstimates? feeEstimates,
    FeeOptionInput? feeOptionInput,
    String? giveAsset,
    String? giveAssetQuantityNormalized,
    int? assetBalance,
    FormzSubmissionStatus? submissionStatus,
    AttachedAtomicSwapSell? attachedAtomicSwapSell,
    String? error,
    BigInt? btcPrice,
    int? giveQuantity,
  }) {
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

class SubmitClicked extends SwapCreateListingFormEvent {
  const SubmitClicked();
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
  })  : _composeTransactionUseCase =
            composeTransactionUseCase ?? GetIt.I<ComposeTransactionUseCase>(),
        _composeRepository = composeRepository ?? GetIt.I<ComposeRepository>(),
        _signAndBroadcastTransactionUseCase =
            signAndBroadcastTransactionUseCase ??
                GetIt.I<SignAndBroadcastTransactionUseCase>(),
        _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        super(SwapCreateListingFormModel(
          feeEstimates: feeEstimates,
          address: address,
          feeOptionInput: FeeOptionInput.pure(),
          giveAsset: giveAsset,
          giveQuantity: giveQuantity,
          giveQuantityNormalized: giveQuantityNormalized,
          btcPrice: btcPrice,
          submissionStatus: FormzSubmissionStatus.initial,
        )) {
    on<FeeOptionChanged>(_handleFeeOptionChanged);
    on<SubmitClicked>(_handleSubmitClicked);
  }

  _handleFeeOptionChanged(
    FeeOptionChanged event,
    Emitter<SwapCreateListingFormModel> emit,
  ) {
    final feeOptionInput = FeeOptionInput.dirty(event.value);

    final newState = state.copyWith(feeOptionInput: feeOptionInput);

    emit(newState);
  }

  _handleSubmitClicked(
    SubmitClicked event,
    Emitter<SwapCreateListingFormModel> emit,
  ) async {
    emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));

    print("we clicked submit, huzzah");
  }
}
