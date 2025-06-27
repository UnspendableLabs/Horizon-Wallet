import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/extensions.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/atomic_swap_repository.dart';
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

  Option<AtomicSwapSignModel> get next {
    if (swapIndex + 1 < atomicSwaps.length) {
      return Option.of(atomicSwaps[swapIndex + 1]);
    }
    return const Option.none();
  }
}

sealed class SwapBuySignFormEvent extends Equatable {
  const SwapBuySignFormEvent();

  @override
  List<Object?> get props => [];
}

class SignatureCompleted extends SwapBuySignFormEvent {
  final String signedPsbtHex;

  const SignatureCompleted({required this.signedPsbtHex});
}

class SubmitClicked extends SwapBuySignFormEvent {}

class CloseSignPsbtModalClicked extends SwapBuySignFormEvent {
  const CloseSignPsbtModalClicked();
}

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
  final BitcoinRepository _bitcoinRepository;
  final AtomicSwapRepository _atomicSwapRepository;

  SwapBuySignFormBloc({
    required FeeEstimates feeEstimates,
    required List<AtomicSwap> atomicSwaps,
    required AddressV2 address,
    required this.httpConfig,
    TransactionService? transactionService,
    UtxoRepository? utxoRepository,
    BitcoinRepository? bitcoinRepository,
    AtomicSwapRepository? atomicSwapRepository,
  })  : _transactionService =
            transactionService ?? GetIt.I<TransactionService>(),
        _utxoRepository = utxoRepository ?? GetIt.I<UtxoRepository>(),
        _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        _atomicSwapRepository =
            atomicSwapRepository ?? GetIt.I<AtomicSwapRepository>(),
        super(SwapBuySignFormModel(
            swapIndex: 0,
            atomicSwaps: atomicSwaps
                .map((swap) => AtomicSwapSignModel(
                    address: address,
                    atomicSwap: swap,
                    feeEstimates: feeEstimates,
                    feeOptionInput: FeeOptionInput.pure(),
                    psbtWithArgs: const Option.none(),
                    showSignPsbtModal: false,
                    error: const Option.none()))
                .toList())) {
    on<SubmitClicked>(_handleSubmitClicked);
    on<FeeOptionChanged>(_onFeeOptionChanged);
    on<CloseSignPsbtModalClicked>(_handleCloseSignPsbtModalClicked);
    on<SignatureCompleted>(_handleSignatureCompleted);
  }

  void _handleCloseSignPsbtModalClicked(
    CloseSignPsbtModalClicked event,
    Emitter<SwapBuySignFormModel> emit,
  ) {
    emit(
      updateSwapAtIndex(
          state.swapIndex,
          (swap) => swap.copyWith(
                showSignPsbtModal: Option.of(false),
                psbtWithArgs: Option.none(),
                signatureStatus: FormzSubmissionStatus.initial,
              )),
    );
  }

  _handleSubmitClicked(
    SubmitClicked event,
    Emitter<SwapBuySignFormModel> emit,
  ) async {
    updateSwapAtIndex(
      state.swapIndex,
      (swap) =>
          swap.copyWith(signatureStatus: FormzSubmissionStatus.inProgress),
    );

    final task = TaskEither<String, MakeBuyPsbtReturn>.Do(($) async {
      AddressV2 buyerAddress = state.current.address;
      String sellerAddress = state.current.atomicSwap.sellerAddress;
      int assetUtxoValue = state.current.atomicSwap.assetUtxoValue;
      num satsPerVByte = state.current.getSatsPerVByte;

      final utxoMap = await $(_utxoRepository.getUnattachedUTXOMapForAddressT(
        httpConfig: httpConfig,
        address: buyerAddress,
      ));

      final selected =
          await $(TaskEither.fromEither(selectUtxosForTargetWithFeeT(
        utxoSet: utxoMap.values.toList(),
        targetAmount: state.current.atomicSwap.price.quantity,
        feeRate: satsPerVByte.toInt(), // convert to JS BigInt,
        voutsLength: 1,
        includeChangeOutput: 1,
      )));

      // chat i need to map this to UtxoWithTransaction(utxo: utxo: transation: transaction)
      final utxosWithTransactions = await $(TaskEither.sequenceList(
        selected.utxos
            .map((utxo) => _bitcoinRepository
                .getTransactionT(
                    httpConfig: httpConfig,
                    txid: utxo.txid,
                    onError: (error) =>
                        'Failed to get transaction for UTXO: ${utxo.txid}:${utxo.vout}')
                .map((bitcoinTransaction) => UtxoWithTransaction(
                    utxo: utxo, transaction: bitcoinTransaction)))
            .toList(),
      ));

      // TODO: could be run in parallel with above
      final sellerTransaction = await $(
        _bitcoinRepository.getTransactionT(
          httpConfig: httpConfig,
          txid: state.current.atomicSwap.assetUtxoId.txid,
          onError: (error) =>
              'Failed to get transaction for seller UTXO: ${state.current.atomicSwap.assetUtxoId.txid}',
        ),
      );

      print("seleced sum ${selected.sum}");
      print("selected price ${selected.price}");
      print("atomt swap price ${state.current.atomicSwap.price.quantity}");
      print("selected fee ${selected.fee}");
      print("selected change ${selected.change}");

      return await $(
        TaskEither.fromEither(_transactionService.makeBuyPsbtT(
          buyerAddress: buyerAddress.address,
          sellerAddress: sellerAddress,
          utxos: utxosWithTransactions,
          httpConfig: httpConfig,
          utxoAssetValue: assetUtxoValue,
          sellerTransaction: sellerTransaction,
          sellerVout: state.current.atomicSwap.assetUtxoId.vout,
          price: state.current.atomicSwap.price.quantity
              .toInt(), // TODO: convert to JS BigInt
          change: selected.change.toInt(), // TODO: compute change
          onError: (error) =>
              'Failed to create PSBT for buy transaction: $error',
        )),
      );
    });

    final result = await task.run();

    result.fold((error) {
      print(error);
      emit(updateSwapAtIndex(
          state.swapIndex,
          (swap) => swap.copyWith(
                signatureStatus: FormzSubmissionStatus.failure,
                error: Option.of(error),
              )));
    },
        (unsignedPsbtWithArgs) => emit(updateSwapAtIndex(
            state.swapIndex,
            (swap) => swap.copyWith(
                  signatureStatus: FormzSubmissionStatus.inProgress,
                  psbtWithArgs: Option.of(unsignedPsbtWithArgs),
                  showSignPsbtModal: const Option.of(true),
                ))));
  }

  void _onFeeOptionChanged(
    FeeOptionChanged event,
    Emitter<SwapBuySignFormModel> emit,
  ) {
    emit(
      updateSwapAtIndex(
          state.swapIndex,
          (swap) => swap.copyWith(
                feeOptionInput: FeeOptionInput.dirty(event.value),
              )),
    );
  }

  void _handleSignatureCompleted(
    SignatureCompleted event,
    Emitter<SwapBuySignFormModel> emit,
  ) async {
    emit(
      updateSwapAtIndex(
          state.swapIndex,
          (swap) => swap.copyWith(
                showSignPsbtModal: const Option.of(false),
                signatureStatus: FormzSubmissionStatus.success,
                broadcastStatus: FormzSubmissionStatus.inProgress,
              )),
    );

    final task = _atomicSwapRepository
        .atomicSwapBuyT(
            httpConfig: httpConfig,
            id: state.current.atomicSwap.id,
            psbtHex: event.signedPsbtHex,
            buyerAddress: state.current.address.address)
        .minimumDuration(Duration(seconds: 1, milliseconds: 500));

    final result = await task.run();

    if (result.isLeft()) {
      final error = result.getLeft();

      updateSwapAtIndex(
          state.swapIndex,
          (swap) => swap.copyWith(
                broadcastStatus: FormzSubmissionStatus.failure,
                error: Option.of(error).getOrThrow(),
              ));
    } else {
      final success = result.getRight().getOrThrow();

      emit(updateSwapAtIndex(
          state.swapIndex,
          (swap) => swap.copyWith(
                broadcastStatus: FormzSubmissionStatus.success,
              )));
      await Future.delayed(const Duration(seconds: 1));


      if (state.next.isNone()) {
        print("no next swap, done");
        return;
      } else {
        emit(
          state.copyWith(
            swapIndex: state.swapIndex + 1,
          ),
        );
      }
    }
  }

  SwapBuySignFormModel updateSwapAtIndex(
    int index,
    AtomicSwapSignModel Function(AtomicSwapSignModel) update,
  ) {
    final updated = update(state.atomicSwaps[index]);
    final newSwaps = List<AtomicSwapSignModel>.from(state.atomicSwaps);
    newSwaps[index] = updated;
    return state.copyWith(atomicSwaps: newSwaps);
  }
}
