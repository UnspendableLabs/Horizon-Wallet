import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import "package:horizon/domain/entities/bitcoin_tx.dart";
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/atomic_swap_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/entities/http_config.dart' hide Custom;

// this is ported over directly from horozn market
int calculateTxBytesFeeWithRate({
  required int vinsLength,
  required int voutsLength,
  required num feeRate,
  int includeChangeOutput = 1,
}) {
  const int baseTxSize = 10;
  const int inSize = 68; // 180 for legacy
  const int outSize = 31; // 34 for legacy

  final int txSize = baseTxSize +
      (vinsLength * inSize) +
      (voutsLength * outSize) +
      (includeChangeOutput * outSize);

  final fee = (txSize * feeRate).ceil(); // use ceil to avoid underpaying
  return fee;
}

class SelectUtxosReturn {
  final List<Utxo> utxos;
  final BigInt price;
  final BigInt fee;

  SelectUtxosReturn({
    required this.utxos,
    required this.price,
    required this.fee,
  });

  BigInt get sum {
    return utxos.fold(
        BigInt.zero, (acc, utxo) => acc + BigInt.from(utxo.value));
  }

  BigInt get change {
    return sum - (price + fee);
  }
}

SelectUtxosReturn selectUtxosForTargetWithFee({
  required List<Utxo> utxoSet,
  required BigInt price,
  required num feeRate,
  int voutsLength = 1,
  int includeChangeOutput = 1,
}) {
  // Sort UTXOs in descending order by value
  final utxos = [...utxoSet]..sort((a, b) => b.value - a.value);

  List<Utxo> selected = [];
  BigInt total = BigInt.zero;
  BigInt fee = BigInt.zero;

  for (int i = 0; i < utxos.length; i++) {
    final utxo = utxos[i];
    selected.add(utxo);
    total += BigInt.from(utxo.value);

    final vsize = calculateTxBytesFeeWithRate(
      vinsLength: selected.length,
      voutsLength: voutsLength,
      feeRate: feeRate,
      includeChangeOutput: includeChangeOutput,
    );

    fee = BigInt.from((vsize * feeRate).ceil());

    if (total >= price + fee) {
      break;
    }
  }

  if (total < price + fee) {
    throw Exception('Insufficient funds');
  }

  return SelectUtxosReturn(
    utxos: selected,
    price: price,
    fee: fee,
  );
}

Either<String, SelectUtxosReturn> selectUtxosForTargetWithFeeT({
  required List<Utxo> utxoSet,
  required BigInt targetAmount,
  required num feeRate,
  int voutsLength = 1,
  int includeChangeOutput = 1,
  String Function(Object error, StackTrace stackTrace)? onError,
}) {
  return Either.tryCatch(
      () => selectUtxosForTargetWithFee(
            utxoSet: utxoSet,
            price: targetAmount,
            feeRate: feeRate,
            voutsLength: voutsLength,
            includeChangeOutput: includeChangeOutput,
          ),
      (error, stackTrace) =>
          onError != null ? onError(error, stackTrace) : error.toString());
}

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
  final FormzSubmissionStatus signatureStatus;
  final FormzSubmissionStatus broadcastStatus;

  final Option<String> error;
  final Option<MakeBuyPsbtReturn> psbtWithArgs;

  final bool showSignPsbtModal;

  const AtomicSwapSignModel(
      {required this.address,
      required this.atomicSwap,
      this.signatureStatus = FormzSubmissionStatus.initial,
      this.broadcastStatus = FormzSubmissionStatus.initial,
      required this.feeEstimates,
      required this.feeOptionInput,
      required this.error,
      required this.psbtWithArgs,
      required this.showSignPsbtModal});

  @override
  List<FormzInput> get inputs => [];

  AtomicSwapSignModel copyWith(
      {AddressV2? address,
      AtomicSwap? atomicSwap,
      FeeEstimates? feeEstimates,
      FeeOptionInput? feeOptionInput,
      FormzSubmissionStatus? signatureStatus,
      FormzSubmissionStatus? broadcastStatus,
      Option<String>? error,
      Option<MakeBuyPsbtReturn>? psbtWithArgs,
      Option<bool> showSignPsbtModal = const None()}) {
    return AtomicSwapSignModel(
        address: address ?? this.address,
        atomicSwap: atomicSwap ?? this.atomicSwap,
        feeEstimates: feeEstimates ?? this.feeEstimates,
        feeOptionInput: feeOptionInput ?? this.feeOptionInput,
        signatureStatus: signatureStatus ?? this.signatureStatus,
        broadcastStatus: broadcastStatus ?? this.broadcastStatus,
        psbtWithArgs: psbtWithArgs ?? this.psbtWithArgs,
        error: error ?? this.error,
        showSignPsbtModal:
            showSignPsbtModal.getOrElse(() => this.showSignPsbtModal));
  }

  String get rateString {
    return '1 ${atomicSwap.assetName} = ${atomicSwap.pricePerUnit.normalizedPretty(precision: 8)} BTC';
  }

  num get getSatsPerVByte => switch (feeOptionInput.value) {
        Slow() => feeEstimates.slow,
        Medium() => feeEstimates.medium,
        Fast() => feeEstimates.fast,
        Custom(fee: var value) => value
      };
}

class SwapMultiBuySignFormModel {
  final AddressV2 address;
  final List<AtomicSwap> atomicSwaps;
  final FeeEstimates feeEstimates;
  final FeeOptionInput feeOptionInput;
  final FormzSubmissionStatus signatureStatus;
  final Option<String> error;
  final Option<MakeBuyPsbtReturn> psbtWithArgs;
  final bool showSignPsbtModal;

  SwapMultiBuySignFormModel({
    required this.address,
    required this.atomicSwaps,
    required this.feeEstimates,
    required this.feeOptionInput,
    required this.signatureStatus,
    required this.error,
    required this.psbtWithArgs,
    required this.showSignPsbtModal,
  });

  SwapMultiBuySignFormModel copyWith(
      {AddressV2? address,
      List<AtomicSwap>? atomicSwaps,
      FeeEstimates? feeEstimates,
      FeeOptionInput? feeOptionInput,
      FormzSubmissionStatus? signatureStatus,
      Option<String>? error,
      Option<MakeBuyPsbtReturn>? psbtWithArgs,
      bool? showSignPsbtModal}) {
    return SwapMultiBuySignFormModel(
      address: address ?? this.address,
      atomicSwaps: atomicSwaps ?? this.atomicSwaps,
      feeEstimates: feeEstimates ?? this.feeEstimates,
      feeOptionInput: feeOptionInput ?? this.feeOptionInput,
      signatureStatus: signatureStatus ?? this.signatureStatus,
      error: error ?? this.error,
      psbtWithArgs: psbtWithArgs ?? this.psbtWithArgs,
      showSignPsbtModal: showSignPsbtModal ?? this.showSignPsbtModal,
    );
  }

  num get getSatsPerVByte => switch (feeOptionInput.value) {
        Slow() => feeEstimates.slow,
        Medium() => feeEstimates.medium,
        Fast() => feeEstimates.fast,
        Custom(fee: var value) => value
      };
}

sealed class SwapMultiBuySignFormEvent extends Equatable {
  const SwapMultiBuySignFormEvent();

  @override
  List<Object?> get props => [];
}

class SignatureCompleted extends SwapMultiBuySignFormEvent {
  final String signedPsbtHex;

  const SignatureCompleted({required this.signedPsbtHex});
}

class SubmitClicked extends SwapMultiBuySignFormEvent {}

class CloseSignPsbtModalClicked extends SwapMultiBuySignFormEvent {
  const CloseSignPsbtModalClicked();
}

class FeeOptionChanged extends SwapMultiBuySignFormEvent {
  final FeeOption value;
  const FeeOptionChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class SwapMultiBuySignFormBloc
    extends Bloc<SwapMultiBuySignFormEvent, SwapMultiBuySignFormModel> {
  final HttpConfig httpConfig;
  final TransactionService _transactionService;
  final UtxoRepository _utxoRepository;
  final BitcoinRepository _bitcoinRepository;
  final ComposeRepository _composeRepository;
  // final AtomicSwapRepository _atomicSwapRepository;

  SwapMultiBuySignFormBloc({
    required FeeEstimates feeEstimates,
    required List<AtomicSwap> atomicSwaps,
    required AddressV2 address,
    required this.httpConfig,
    TransactionService? transactionService,
    UtxoRepository? utxoRepository,
    BitcoinRepository? bitcoinRepository,
    AtomicSwapRepository? atomicSwapRepository,
    ComposeRepository? composeRepository,
  })  : _transactionService =
            transactionService ?? GetIt.I<TransactionService>(),
        _utxoRepository = utxoRepository ?? GetIt.I<UtxoRepository>(),
        _composeRepository = composeRepository ?? GetIt.I<ComposeRepository>(),
        _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        // _atomicSwapRepository =
        //     atomicSwapRepository ?? GetIt.I<AtomicSwapRepository>(),
        super(SwapMultiBuySignFormModel(
          address: address,
          atomicSwaps: atomicSwaps,
          signatureStatus: FormzSubmissionStatus.initial,
          feeOptionInput: FeeOptionInput.pure(),
          feeEstimates: feeEstimates,
          psbtWithArgs: const Option.none(),
          error: const Option.none(),
          showSignPsbtModal: false,
        )) {
    on<SubmitClicked>(_handleSubmitClicked);
    on<FeeOptionChanged>(_onFeeOptionChanged);
    on<CloseSignPsbtModalClicked>(_handleCloseSignPsbtModalClicked);
    on<SignatureCompleted>(_handleSignatureCompleted);
  }

  void _handleCloseSignPsbtModalClicked(
    CloseSignPsbtModalClicked event,
    Emitter<SwapMultiBuySignFormModel> emit,
  ) {
    emit(state.copyWith(
      showSignPsbtModal: false,
      psbtWithArgs: const Option.none(),
      signatureStatus: FormzSubmissionStatus.initial,
    ));
  }

  _handleSubmitClicked(
    SubmitClicked event,
    Emitter<SwapMultiBuySignFormModel> emit,
  ) async {
    emit(state.copyWith(
      signatureStatus: FormzSubmissionStatus.inProgress,
    ));

    // TODO: royalties; detachData
    final task = TaskEither<String, MakeBuyPsbtReturn>.Do(($) async {
      AddressV2 buyerAddress = state.address;

      num satsPerVByte = state.getSatsPerVByte;

      // ignore  royalities fo now
      int royaltyAmount = 0;

      List<(AtomicSwap, BitcoinTx)> swapsWithTransactions =
          await $(TaskEither.sequenceList(state.atomicSwaps
              .map((swap) => _bitcoinRepository
                  .getTransactionT(
                    httpConfig: httpConfig,
                    txid: swap.assetUtxoId.txid,
                    onError: (error) =>
                        'Failed to get transaction for atomic swap UTXO: ${swap.assetUtxoId.txid}',
                  )
                  .map((tx) => (swap, tx)))
              .toList()));

      List<UtxoWithTransaction> utxosWithTransactions = await $(_utxoRepository
          .getUnattachedUTXOMapForAddressT(
            httpConfig: httpConfig,
            address: buyerAddress,
          )
          .map((m) => m.values.toList())
          .flatMap(
            (utxos) => TaskEither.sequenceList(
              utxos
                  .map((utxo) => _bitcoinRepository
                      .getTransactionT(
                        httpConfig: httpConfig,
                        txid: utxo.txid,
                        onError: (error) =>
                            'Failed to get transaction for UTXO: ${utxo.txid}:${utxo.vout}',
                      )
                      .map((bitcoinTransaction) => UtxoWithTransaction(
                          utxo: utxo, transaction: bitcoinTransaction)))
                  .toList(),
            ),
          ));

      for (var utxo in utxosWithTransactions) {
        print("utxo: ${utxo}");
      }

      final detachData = await $(_composeRepository.getDetachDataT(
        destination: buyerAddress.address,
        httpConfig: httpConfig,
        onError: (error, st) => 'Failed to get detach data: $error \n\n$st',
      ));

      return await $(_transactionService.makeMultiBuyPsbtT(
        buyerAddress: buyerAddress.address,
        swapsWithSellerTransactions: swapsWithTransactions,
        utxosWithBuyerTransactions: utxosWithTransactions,
        httpConfig: httpConfig,
        royaltyAmount: royaltyAmount,
        feeRate: satsPerVByte.toDouble(),
        detachData: detachData,
        onError: (error, st) =>
            'Failed to create PSBT for multi-buy: $error \n\n$st',
      ));
    });

    final result = await task.run();

    final nextState = result.fold((error) {
      print("error: $error");
      return state.copyWith(
        signatureStatus: FormzSubmissionStatus.failure,
        error: Option.of(error),
      );
    }, (unsignedPsbtWithArgs) {
      return state.copyWith(
        signatureStatus: FormzSubmissionStatus.inProgress,
        psbtWithArgs: Option.of(unsignedPsbtWithArgs),
        showSignPsbtModal: true,
      );
    });

    emit(nextState);
  }

  void _onFeeOptionChanged(
    FeeOptionChanged event,
    Emitter<SwapMultiBuySignFormModel> emit,
  ) {
    emit(state.copyWith(
      feeOptionInput: FeeOptionInput.dirty(event.value),
    ));
  }

  void _handleSignatureCompleted(
    SignatureCompleted event,
    Emitter<SwapMultiBuySignFormModel> emit,
  ) async {
    emit(state.copyWith(
      showSignPsbtModal: false,
      signatureStatus: FormzSubmissionStatus.success,
    ));

    // final task = _atomicSwapRepository
    //     .atomicSwapMultiBuyT(
    //         httpConfig: httpConfig,
    //         ids: state.atomicSwaps.map((swap) => swap.id).toList(),
    //         psbtHex: event.signedPsbtHex,
    //         buyerAddress: state.address.address)
    //     .minimumDuration(const Duration(seconds: 1, milliseconds: 500));
    //
    // final result = await task.run();
    //
    // if (result.isLeft()) {
    //   // final error = result.getLeft();
    //
    //   updateSwapAtIndex(
    //       state.swapIndex,
    //       (swap) => swap.copyWith(
    //             broadcastStatus: FormzSubmissionStatus.failure,
    //             // error: Option.of(error).getOrThrow(),
    //           ));
    // } else {
    //   // final success = result.getRight().getOrThrow();
    //
    //   emit(updateSwapAtIndex(
    //       state.swapIndex,
    //       (swap) => swap.copyWith(
    //             broadcastStatus: FormzSubmissionStatus.success,
    //           )));
    //   await Future.delayed(const Duration(seconds: 1));
    //
    //   if (state.next.isNone()) {
    //     emit(state.copyWith(allSigned: const Option.of(true)));
    //     return;
    //   } else {
    //     emit(
    //       state.copyWith(
    //         swapIndex: state.swapIndex + 1,
    //       ),
    //     );
    //   }
    // }
  }
}
