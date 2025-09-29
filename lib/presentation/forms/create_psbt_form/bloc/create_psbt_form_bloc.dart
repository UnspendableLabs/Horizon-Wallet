import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/royalty_by_asset.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/common/constants.dart';

import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/address_v2.dart';

import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/domain/services/seed_service.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/address_service.dart';

BigInt _calculateMinPrice(RoyaltyByAsset royalty, BigInt dust, int voutValue) {
  final baseMinimum = [
    dust,
    BigInt.from(voutValue),
  ].reduce((max, curr) => curr > max ? curr : max);

  final royaltyPercent =
      Decimal.fromInt(royalty.royalty) / Decimal.fromInt(10000);

  final minPriceForRoyalty = (dust.toDecimal() *
          Decimal.fromInt(10000) /
          Decimal.fromInt(royalty.royalty))
      .ceil();

  final minPriceForTotalReceive = (Decimal.fromBigInt(baseMinimum) /
          (Decimal.one - royaltyPercent.toDecimal()))
      .ceil();

  return [
    minPriceForRoyalty,
    minPriceForTotalReceive,
  ].reduce((max, curr) => curr > max ? curr : max);
}

enum BtcPriceInputError {
  required,
  isNaN,
  isNegative,
  isDust,
  isTooSmallBecauseOfRoyalty
}

class BtcPriceInput extends FormzInput<String, BtcPriceInputError> {
  final BigInt minPrice;

  const BtcPriceInput.pure({required this.minPrice}) : super.pure('');
  const BtcPriceInput.dirty({
    required String value,
    required this.minPrice,
  }) : super.dirty(value);
  @override
  BtcPriceInputError? validator(String value) {
    if (value.isEmpty) {
      return BtcPriceInputError.required;
    }

    BtcPriceInputError? royaltyError = asSats.fold(() => null, (sats) {
      if (sats < minPrice) {
        return BtcPriceInputError.isTooSmallBecauseOfRoyalty;
      }
      return null;
    });

    if (royaltyError != null) {
      return royaltyError;
    }

    BtcPriceInputError? dustError = asSats.fold(
      () => null,
      (sats) => sats <= dust ? BtcPriceInputError.isDust : null,
    );

    if (dustError != null) {
      return dustError;
    }

    return asDecimal.fold(
      () => BtcPriceInputError.isNaN,
      (decimal) =>
          decimal <= Decimal.zero ? BtcPriceInputError.isNegative : null,
    );
  }

  Option<Decimal> get asDecimal {
    return Option.tryCatch(() => Decimal.parse(value));
  }

  Option<BigInt> get asSats {
    // chat, wihtha  value decimal value of 0.02, this returns 0
    return asDecimal.map((d) => d * Decimal.fromInt(100000000)).map(
          (d) => d.toBigInt(),
        );
  }
}

class CreatePsbtFormModel with FormzMixin {
  final Option<RoyaltyByAsset> assetRoyalty;

  final BitcoinTx utxoTransaction;
  final UtxoID utxoID;

  final BtcPriceInput btcPriceInput;
  final FormzSubmissionStatus submissionStatus;

  final bool showSignPsbtModal;
  final Option<String> unsignedPsbtHex;

  final DateTime? expiryDate;
  final String? error;
  final String? signedPsbt;

  CreatePsbtFormModel(
      {required this.utxoID,
      required this.btcPriceInput,
      required this.submissionStatus,
      required this.showSignPsbtModal,
      required this.unsignedPsbtHex,
      required this.utxoTransaction,
      this.expiryDate,
      this.error,
      this.signedPsbt,
      required this.assetRoyalty});

  @override
  List<FormzInput> get inputs => [btcPriceInput];

  CreatePsbtFormModel copyWith(
          {Option<RoyaltyByAsset>? assetRoyalty,
          UtxoID? utxoID,
          BitcoinTx? utxoTransaction,
          BtcPriceInput? btcPriceInput,
          DateTime? expiryDate,
          FormzSubmissionStatus? submissionStatus,
          String? error,
          String? signedPsbt,
          Option<String>? unsignedPsbtHex,
          Option<bool> showSignPsbtModal = const None()}) =>
      CreatePsbtFormModel(
        utxoID: utxoID ?? this.utxoID,
        utxoTransaction: utxoTransaction ?? this.utxoTransaction,
        assetRoyalty: assetRoyalty ?? this.assetRoyalty,
        unsignedPsbtHex: unsignedPsbtHex ?? this.unsignedPsbtHex,
        showSignPsbtModal:
            showSignPsbtModal.getOrElse(() => this.showSignPsbtModal),
        btcPriceInput: btcPriceInput ?? this.btcPriceInput,
        expiryDate: expiryDate ?? this.expiryDate,
        submissionStatus: submissionStatus ?? this.submissionStatus,
        error: error ?? this.error,
        signedPsbt: signedPsbt ?? this.signedPsbt,
      );

  get submitDisabled => isNotValid || submissionStatus.isInProgress;

  Vout get vout => utxoTransaction.vout[utxoID.vout];

  BigInt get minPrice => assetRoyalty.fold(() => dust, (royalty) {
        return _calculateMinPrice(royalty, dust, vout.value);
      });

  BigInt get royaltyAmount => assetRoyalty.fold(() => BigInt.zero, (royalty) {
        return (Decimal.fromBigInt(
                    btcPriceInput.asSats.getOrElse(() => BigInt.zero)) *
                Decimal.fromInt(royalty.royalty) /
                Decimal.fromInt(10000))
            .floor();
      });
}

sealed class CreatePsbtFormEvent extends Equatable {
  const CreatePsbtFormEvent();

  @override
  List<Object?> get props => [];
}

class BtcPriceInputChanged extends CreatePsbtFormEvent {
  final String value;

  const BtcPriceInputChanged({required this.value});
}

class SubmitClicked extends CreatePsbtFormEvent {}

class CloseSignPsbtModalClicked extends CreatePsbtFormEvent {
  const CloseSignPsbtModalClicked();
}

class SignatureCompleted extends CreatePsbtFormEvent {
  final String signedPsbtHex;

  const SignatureCompleted({required this.signedPsbtHex});
}

class ExpiryDateSelected extends CreatePsbtFormEvent {
  final DateTime? date;

  const ExpiryDateSelected({this.date});
}

class CreatePsbtFormBloc
    extends Bloc<CreatePsbtFormEvent, CreatePsbtFormModel> {
  final AddressV2 address;

  final UtxoID utxoID;
  final HttpConfig httpConfig;

  final BitcoinRepository _bitcoinRepository;
  final TransactionService _transactionService;

  final WalletConfigRepository _walletConfigRepository;
  final SeedService _seedService;
  final InMemoryKeyRepository _inMemoryKeyRepository;

  final EncryptionService _encryptionService;
  final AddressService _addressService;

  CreatePsbtFormBloc({
    required Option<RoyaltyByAsset> assetRoyalty,
    required this.address,
    required this.httpConfig,
    required this.utxoID,
    required BitcoinTx utxoTransaction,
    BitcoinRepository? bitcoinRepository,
    TransactionService? transactionService,
    WalletConfigRepository? walletConfigRepository,
    SeedService? seedService,
    InMemoryKeyRepository? inMemoryKeyRepository,
    EncryptionService? encryptionService,
    AddressService? addressService,
  })  : _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        _transactionService =
            transactionService ?? GetIt.I<TransactionService>(),
        _walletConfigRepository =
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>(),
        _seedService = seedService ?? GetIt.I<SeedService>(),
        _inMemoryKeyRepository =
            inMemoryKeyRepository ?? GetIt.I<InMemoryKeyRepository>(),
        _encryptionService = encryptionService ?? GetIt.I<EncryptionService>(),
        _addressService = addressService ?? GetIt.I<AddressService>(),
        super(
          CreatePsbtFormModel(
            utxoID: utxoID,
            utxoTransaction: utxoTransaction,
            assetRoyalty: assetRoyalty,
            showSignPsbtModal: false,
            unsignedPsbtHex: const None(),
            btcPriceInput: BtcPriceInput.pure(
                minPrice: assetRoyalty.fold(
                    () => dust,
                    (royalty) => _calculateMinPrice(
                        royalty,
                        dust,
                        utxoTransaction
                            .vout[utxoID.vout].value))), // temp value
            submissionStatus: FormzSubmissionStatus.initial,
          ),
        ) {
    on<BtcPriceInputChanged>(_onBtcPriceInputChanged); // handler wired up once
    on<SubmitClicked>(_onSubmitClicked);
    on<CloseSignPsbtModalClicked>(_onCloseSignPsbtModalClicked);
    on<SignatureCompleted>((event, emit) {
      emit(state.copyWith(
        showSignPsbtModal: const Option.of(false),
        signedPsbt: event.signedPsbtHex,
        submissionStatus: FormzSubmissionStatus.success,
      ));

      emit(state.copyWith(
        showSignPsbtModal: const Option.of(false),
        signedPsbt: event.signedPsbtHex,
        submissionStatus: FormzSubmissionStatus.initial,
      ));
    });
    on<ExpiryDateSelected>(_onExpiryDateSelected);
  }

  void _onExpiryDateSelected(
      ExpiryDateSelected event, Emitter<CreatePsbtFormModel> emit) {
    emit(state.copyWith(expiryDate: event.date));
  }

  // give the handler an explicit return type
  void _onBtcPriceInputChanged(
    BtcPriceInputChanged event,
    Emitter<CreatePsbtFormModel> emit,
  ) {
    final btcPriceInput =
        BtcPriceInput.dirty(minPrice: state.minPrice, value: event.value);

    emit(
      state.copyWith(
        showSignPsbtModal: const Option.of(false),
        unsignedPsbtHex: const Option.none(),
        btcPriceInput: btcPriceInput, // mark it dirty
        submissionStatus: FormzSubmissionStatus.initial,
      ),
    );
  }

  Future<void> _onSubmitClicked(
    SubmitClicked event,
    Emitter<CreatePsbtFormModel> emit,
  ) async {
    emit(state.copyWith(
      submissionStatus: FormzSubmissionStatus.inProgress,
      // TODO: just get rid of this
    ));

    final attachTxID = utxoID.txid;
    final voutIndex = utxoID.vout;

    final task = TaskEither<String, String>.Do(($) async {
      final tx = state.utxoTransaction;

      final priceInSats = await $(TaskEither.fromOption(
          state.btcPriceInput.asSats,
          () => "Error parsing BTC price input as sats"));

      final royaltyAmount = state.assetRoyalty.fold(
          () => BigInt.zero,
          (royalty) => (Decimal.fromBigInt(priceInSats) *
                  Decimal.fromInt(royalty.royalty) /
                  Decimal.fromInt(10000))
              .floor());

      final totalPrice = priceInSats - royaltyAmount;

      final newSalePsbtHex = await $(_transactionService.makeSalePsbtT(
          price: totalPrice,
          source: address.address,
          utxoTxid: attachTxID,
          utxoVoutIndex: voutIndex,
          utxoVout: tx.vout[voutIndex],
          httpConfig: httpConfig,
          onError: (err) => err.toString()));

      return newSalePsbtHex;
    });

    emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));

    final result = await task.run();

    final nextState = result.fold((err) {
      return state.copyWith(
          error: err.toString(),
          submissionStatus: FormzSubmissionStatus.failure);
    }, (psbtHex) {
      return state.copyWith(
        unsignedPsbtHex: Option.of(psbtHex),
        showSignPsbtModal: const Option.of(true),
      );
      // submissionStatus: FormzSubmissionStatus.success));
    });

    emit(nextState);
  }

  void _onCloseSignPsbtModalClicked(
    CloseSignPsbtModalClicked event,
    Emitter<CreatePsbtFormModel> emit,
  ) {
    emit(state.copyWith(
      showSignPsbtModal: const Option.of(false),
      unsignedPsbtHex: const None(),
      submissionStatus: FormzSubmissionStatus.initial,
    ));
  }
}
